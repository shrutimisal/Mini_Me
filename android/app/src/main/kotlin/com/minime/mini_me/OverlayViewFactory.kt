package com.minime.mini_me

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView

class OverlayViews(val root: View, val bubble: View)

/** Builds the overlay layout: [speech bubble] [close button over avatar]. */
object OverlayViewFactory {
    fun create(
        ctx: Context,
        message: String,
        avatar: Avatar,
        onClose: () -> Unit,
    ): OverlayViews {
        val d = ctx.resources.displayMetrics.density
        fun dp(v: Int) = (v * d).toInt()

        val bubble = TextView(ctx).apply {
            text = message
            textSize = 14f
            maxWidth = dp(190)
            setTextColor(Color.parseColor("#222222"))
            setPadding(dp(12), dp(8), dp(12), dp(8))
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                cornerRadius = dp(14).toFloat()
                setStroke(dp(1), Color.parseColor("#CCCCCC"))
            }
            alpha = 0f // fades in once the avatar has arrived
        }

        val close = TextView(ctx).apply {
            text = "✕"
            textSize = 12f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#99000000"))
            }
            setOnClickListener { onClose() }
        }

        val column = LinearLayout(ctx).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.END
            addView(close, LinearLayout.LayoutParams(dp(26), dp(26)))
            addView(avatar.view, LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        }

        val root = LinearLayout(ctx).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.BOTTOM
            setPadding(dp(4), dp(4), dp(4), dp(4))
            addView(bubble, LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { setMargins(0, 0, dp(6), dp(12)) })
            addView(column)
        }
        return OverlayViews(root, bubble)
    }
}
