import 'package:shared_preferences/shared_preferences.dart';

import '../../features/overlay/overlay_controller.dart';
import '../../features/reminders/reminders_controller.dart';
import '../../features/reminders/services/reminder_repository.dart';
import '../../features/reminders/services/reminder_scheduler.dart';
import '../../features/settings/settings_controller.dart';
import '../permissions/permissions_controller.dart';
import '../platform/native_bridge.dart';

/// Simple service locator: one instance of each controller for the whole app.
class AppServices {
  AppServices._({
    required this.permissions,
    required this.overlay,
    required this.reminders,
    required this.settings,
  });

  final PermissionsController permissions;
  final OverlayController overlay;
  final RemindersController reminders;
  final SettingsController settings;

  static late AppServices instance;

  static Future<AppServices> init() async {
    const bridge = NativeBridge();
    final prefs = await SharedPreferences.getInstance();
    final services = AppServices._(
      permissions: PermissionsController(bridge),
      overlay: OverlayController(bridge),
      reminders: RemindersController(ReminderRepository(prefs), ReminderScheduler(bridge)),
      settings: SettingsController(prefs, bridge),
    );
    instance = services;
    await services.settings.load();
    await services.reminders.load();
    await services.permissions.refresh();
    return services;
  }
}
