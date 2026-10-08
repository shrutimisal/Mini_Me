# Avatar

The avatar is rendered natively (the overlay is a Kotlin `WindowManager` view, not Flutter).

To replace the emoji placeholder, implement the `Avatar` interface in
`android/app/src/main/kotlin/com/minime/mini_me/Avatar.kt`
(`view`, `startWalking()`, `startIdle()`, `release()`) and return it from `AvatarFactory.create`.
Ideas: `ImageView` + PNG frames, an `AnimationDrawable` sprite sheet, or a Lottie/Rive native view.
Put source art in `assets/avatars/` (copy into `android/app/src/main/res/drawable*` for native use).
