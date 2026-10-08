# 🧸 MiniMe — Animated Reminder Companion

**MiniMe** is an Android-only Flutter application that turns normal reminders into an interactive experience. At the scheduled time, a small animated avatar appears **over the currently open app**, displays a reminder message, waits for a few seconds, and exits.

### ✨ Key Features

| Feature                     | Status |
| --------------------------- | ------ |
| Create & manage reminders   | ✅      |
| Exact alarm scheduling      | ✅      |
| Background alarm triggering | ✅      |
| Android overlay             | ✅      |
| Animated avatar             | ✅      |
| Reminder speech bubble      | ✅      |
| Local reminder storage      | ✅      |
| Physical Android testing    | ✅      |

### 🛠️ Tech Stack

**Flutter • Dart • Kotlin • Android AlarmManager • WindowManager • SharedPreferences • Platform Channels**

### 🏗️ Basic Architecture

```text
Flutter UI
   ↓
SharedPreferences
   ↓
Android AlarmManager
   ↓
BroadcastReceiver
   ↓
Kotlin Overlay Service
   ↓
🧸 MiniMe Avatar + Reminder
```

### 💾 Storage

A database is **not required currently**. Reminders and settings are stored locally using **SharedPreferences**.

A database/cloud backend can be added later if features such as reminder history, synchronization, or user accounts are introduced.

---

## 🐛 Development & Errors Faced

| Issue                                  | Cause                                         | Fix                                                   |
| -------------------------------------- | --------------------------------------------- | ----------------------------------------------------- |
| `OverlayResult` not defined            | Missing import                                | Added `overlay_controller.dart` import                |
| Android v1 embedding error             | Old Flutter Android embedding                 | Updated project to modern Android embedding           |
| Wireless ADB pairing failed            | Phone and Mac couldn't communicate over Wi-Fi | Switched to USB debugging                             |
| `No route to host`                     | Network isolation/routing issue               | Used USB + USB hub                                    |
| Flutter device not initially available | Device connection/setup                       | Enabled USB debugging and verified with `adb devices` |

### 📱 Final Device Test

Flutter successfully detected the physical Android device:

```text
V2228 • Android 15 • API 35
```

The core flow was successfully tested:

```text
Scheduled Alarm
      ↓
Background Trigger
      ↓
Overlay Appears
      ↓
🧸 Avatar + Message
      ↓
Avatar Exits
```

## 🔮 Future Improvements

* 🎨 Improved UI
* 🧸 More avatars & animations
* 🔔 Advanced reminder options
* 🤖 AI-powered interactions
* ☁️ Optional cloud/database support

---

### 📌 Project Status

**Functional Android prototype — core reminder and overlay system successfully implemented and tested on a physical device.**
