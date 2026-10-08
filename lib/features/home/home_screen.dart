import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/services/app_services.dart';
import '../../shared/helpers/snackbar.dart';
import '../overlay/overlay_controller.dart';
import '../reminders/widgets/reminder_tile.dart';
import 'widgets/permission_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _services = AppServices.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Returning from a system settings screen: re-read permissions, and re-register
  // alarms so they become exact if exact-alarm access was just granted.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _services.permissions.refresh().then((_) => _services.reminders.resync());
    }
  }

  Future<void> _showOverlay({Duration? duration, Duration delay = Duration.zero}) async {
    final messenger = ScaffoldMessenger.of(context);
    if (delay > Duration.zero) {
      messenger.showSnackBar(SnackBar(
        content: Text('MiniMe will appear in ${delay.inSeconds} s. Switch to another app now!'),
      ));
      await Future<void>.delayed(delay);
    }
    final result = await _services.overlay.show(duration: duration);
    switch (result) {
      case OverlayResult.ok:
        break;
      case OverlayResult.permissionMissing:
        await _services.permissions.refresh();
        messenger.showSnackBar(const SnackBar(
            content: Text('Overlay permission is not granted. Tap "Grant Overlay Permission".')));
      case OverlayResult.failed:
        messenger.showSnackBar(const SnackBar(
            content: Text('Could not start MiniMe. Check notification/battery settings and try again.')));
    }
  }

  Future<void> _toggle(String id, bool enabled) async {
    final error = await _services.reminders.setEnabled(id, enabled);
    if (error != null && mounted) showMessage(context, error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniMe 👧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_services.permissions, _services.reminders]),
        builder: (context, _) {
          final reminders = _services.reminders.items;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Your little personal companion',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              PermissionCard(permissions: _services.permissions),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _showOverlay(duration: Duration.zero),
                      child: const Text('Show MiniMe'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _services.overlay.hide,
                      child: const Text('Hide MiniMe'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _showOverlay(),
                child: const Text('Test MiniMe Now'),
              ),
              TextButton(
                onPressed: () => _showOverlay(delay: const Duration(seconds: 5)),
                child: const Text('Test in 5 seconds (then open YouTube)'),
              ),
              const Divider(height: 32),
              Text('My Reminders', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (reminders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No reminders yet. Tap "Add Reminder" to create one.'),
                ),
              for (final r in reminders)
                Dismissible(
                  key: ValueKey(r.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _services.reminders.delete(r.id),
                  child: ReminderTile(
                    reminder: r,
                    onToggle: (v) => _toggle(r.id, v),
                    onTap: () => Navigator.pushNamed(context, Routes.editReminder, arguments: r),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, Routes.editReminder),
                icon: const Icon(Icons.add),
                label: const Text('Add Reminder'),
              ),
            ],
          );
        },
      ),
    );
  }
}
