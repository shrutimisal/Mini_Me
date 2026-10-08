package com.minime.mini_me

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.media.RingtoneManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.animation.ValueAnimator

/** Owns the overlay window lifecycle: add, slide in, idle, slide out, remove. Main thread only. */
class OverlayManager(private val context: Context) {

    private enum class State { NONE, ENTERING, VISIBLE, EXITING }

    private val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val handler = Handler(Looper.getMainLooper())
    private val density = context.resources.displayMetrics.density

    private var root: View? = null
    private var bubble: View? = null
    private var params: WindowManager.LayoutParams? = null
    private var avatar: Avatar? = null
    private var slide: ValueAnimator? = null
    private var onFinished: (() -> Unit)? = null
    private var state = State.NONE
    private var durationMs = 0L
    private var animationMs = 700L
    private var viewW = 0
    private var viewH = 0

    private val autoExit = Runnable { exit() }

    val isShowing: Boolean get() = root != null

    private fun dp(v: Int) = (v * density).toInt()

    /**
     * Shows the companion. [durationMs] <= 0 keeps it on screen until dismissed.
     * Returns false if the window could not be added.
     */
    fun show(message: String, durationMs: Long, settings: OverlaySettings, onFinished: () -> Unit): Boolean {
        removeNow() // replace any overlay that is already showing

        val metrics = context.resources.displayMetrics
        val screenW = metrics.widthPixels
        val screenH = metrics.heightPixels

        val av = AvatarFactory.create(context, settings)
        val views = OverlayViewFactory.create(context, message, av) { exit() }
        views.root.measure(
            View.MeasureSpec.makeMeasureSpec(screenW, View.MeasureSpec.AT_MOST),
            View.MeasureSpec.makeMeasureSpec(screenH, View.MeasureSpec.AT_MOST)
        )
        viewW = views.root.measuredWidth
        viewH = views.root.measuredHeight

        val targetX = (screenW - viewW - dp(8)).coerceAtLeast(0)
        val maxY = (screenH - viewH).coerceAtLeast(0)
        val targetY = when (settings.position) {
            "top" -> dp(96)
            "bottom" -> screenH - viewH - dp(140)
            else -> (screenH - viewH) / 2
        }.coerceIn(0, maxY)

        val lp = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            // Not focusable so the app underneath keeps keyboard/back handling;
            // NO_LIMITS lets the window start fully off-screen.
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = screenW // start just off the right edge
            y = targetY
        }

        try {
            wm.addView(views.root, lp)
        } catch (e: Exception) {
            Log.e(TAG, "Could not add overlay window", e)
            av.release()
            return false
        }

        root = views.root
        bubble = views.bubble
        params = lp
        avatar = av
        this.onFinished = onFinished
        this.durationMs = durationMs
        this.animationMs = settings.animationMs
        attachDrag(views.root, lp, screenW, screenH)
        if (settings.sound) playSound()

        state = State.ENTERING
        av.startWalking()
        slide = OverlayAnimator.slideX(
            screenW, targetX, animationMs, DecelerateInterpolator(),
            onUpdate = { moveTo(x = it) },
            onEnd = { onArrived() }
        )
        return true
    }

    private fun onArrived() {
        state = State.VISIBLE
        avatar?.startIdle()
        OverlayAnimator.fade(bubble, 1f, 250)
        if (durationMs > 0) handler.postDelayed(autoExit, durationMs)
    }

    /** Slides out then removes. Safe to call repeatedly or when nothing is showing. */
    fun exit() {
        val lp = params
        if (root == null || lp == null) {
            finish()
            return
        }
        if (state == State.EXITING) return
        state = State.EXITING
        handler.removeCallbacks(autoExit)
        slide?.cancel()
        OverlayAnimator.fade(bubble, 0f, 150)
        avatar?.startWalking()
        slide = OverlayAnimator.slideX(
            lp.x, context.resources.displayMetrics.widthPixels, animationMs, AccelerateInterpolator(),
            onUpdate = { moveTo(x = it) },
            onEnd = { finish() }
        )
    }

    private fun finish() {
        val callback = onFinished
        removeNow()
        callback?.invoke()
    }

    /** Immediately tears everything down without animation or callbacks. */
    fun removeNow() {
        handler.removeCallbacks(autoExit)
        slide?.cancel()
        slide = null
        avatar?.release()
        avatar = null
        root?.let {
            try {
                wm.removeViewImmediate(it)
            } catch (e: IllegalArgumentException) {
                // Already detached.
            }
        }
        root = null
        bubble = null
        params = null
        onFinished = null
        state = State.NONE
    }

    private fun moveTo(x: Int? = null, y: Int? = null) {
        val view = root ?: return
        val lp = params ?: return
        if (x != null) lp.x = x
        if (y != null) lp.y = y
        try {
            wm.updateViewLayout(view, lp)
        } catch (e: IllegalArgumentException) {
            // View was removed mid-animation.
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun attachDrag(view: View, lp: WindowManager.LayoutParams, screenW: Int, screenH: Int) {
        var startX = 0
        var startY = 0
        var downX = 0f
        var downY = 0f
        view.setOnTouchListener { _, e ->
            if (state != State.VISIBLE) return@setOnTouchListener false
            when (e.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    startX = lp.x; startY = lp.y
                    downX = e.rawX; downY = e.rawY
                }
                MotionEvent.ACTION_MOVE -> moveTo(
                    x = (startX + (e.rawX - downX).toInt()).coerceIn(0, (screenW - viewW).coerceAtLeast(0)),
                    y = (startY + (e.rawY - downY).toInt()).coerceIn(0, (screenH - viewH).coerceAtLeast(0))
                )
            }
            true
        }
    }

    private fun playSound() {
        try {
            val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            RingtoneManager.getRingtone(context, uri)?.play()
        } catch (e: Exception) {
            Log.w(TAG, "Could not play sound", e)
        }
    }

    companion object {
        private const val TAG = "OverlayManager"
    }
}
