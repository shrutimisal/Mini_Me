/// Channel + method names shared with MainActivity.kt. Keep both sides in sync.
abstract final class NativeChannel {
  static const name = 'com.minime.mini_me/native';

  static const checkOverlayPermission = 'checkOverlayPermission';
  static const openOverlaySettings = 'openOverlaySettings';
  static const showOverlay = 'showOverlay';
  static const hideOverlay = 'hideOverlay';
  static const isOverlayShowing = 'isOverlayShowing';
  static const syncReminders = 'syncReminders';
  static const saveSettings = 'saveSettings';
  static const canScheduleExactAlarms = 'canScheduleExactAlarms';
  static const openExactAlarmSettings = 'openExactAlarmSettings';
  static const checkNotificationPermission = 'checkNotificationPermission';
  static const requestNotificationPermission = 'requestNotificationPermission';
  static const openBatterySettings = 'openBatterySettings';
}
