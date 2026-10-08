package com.minime.mini_me

import android.animation.ObjectAnimator
import android.content.Context
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.LinearInterpolator
import android.widget.TextView

/**
 * Anything that can be shown as the companion. To use a PNG, sprite sheet, Lottie or Rive
 * avatar later, implement this interface and return it from [AvatarFactory.create].
 */
interface Avatar {
    val view: View
    fun startWalking()
    fun startIdle()
    fun release()
}

object AvatarFactory {
    fun create(context: Context, settings: OverlaySettings): Avatar =
        EmojiAvatar(context, "👧", settings.scale)
}

/** Placeholder avatar: an emoji that hops while walking and bobs gently while idle. */
class EmojiAvatar(context: Context, emoji: String, scale: Float) : Avatar {
    private val density = context.resources.displayMetrics.density
    private var animator: ObjectAnimator? = null

    override val view = TextView(context).apply {
        text = emoji
        textSize = 44f * scale
    }

    override fun startWalking() = bob(amplitudeDp = 6f, periodMs = 220)
    override fun startIdle() = bob(amplitudeDp = 3f, periodMs = 1200)

    private fun bob(amplitudeDp: Float, periodMs: Long) {
        animator?.cancel()
        view.translationY = 0f
        animator = ObjectAnimator.ofFloat(view, View.TRANSLATION_Y, 0f, -amplitudeDp * density).apply {
            duration = periodMs
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.REVERSE
            interpolator = if (periodMs < 500) LinearInterpolator() else AccelerateDecelerateInterpolator()
            start()
        }
    }

    override fun release() {
        animator?.cancel()
        animator = null
    }
}
