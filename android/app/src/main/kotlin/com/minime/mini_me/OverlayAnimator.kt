package com.minime.mini_me

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.TimeInterpolator
import android.animation.ValueAnimator
import android.view.View

/** Small reusable animation helpers for the overlay. Swap/extend here to change the motion. */
object OverlayAnimator {
    /** Animates an integer X position. [onEnd] is NOT called if the animator is cancelled. */
    fun slideX(
        from: Int,
        to: Int,
        durationMs: Long,
        interpolator: TimeInterpolator,
        onUpdate: (Int) -> Unit,
        onEnd: () -> Unit,
    ): ValueAnimator = ValueAnimator.ofInt(from, to).apply {
        duration = durationMs
        this.interpolator = interpolator
        addUpdateListener { onUpdate(it.animatedValue as Int) }
        addListener(object : AnimatorListenerAdapter() {
            private var cancelled = false
            override fun onAnimationCancel(animation: Animator) { cancelled = true }
            override fun onAnimationEnd(animation: Animator) { if (!cancelled) onEnd() }
        })
        start()
    }

    fun fade(view: View?, to: Float, durationMs: Long) {
        view?.animate()?.alpha(to)?.setDuration(durationMs)?.start()
    }
}
