import 'package:flutter/material.dart';

import '../../../core/permissions/permissions_controller.dart';

class PermissionCard extends StatelessWidget {
  const PermissionCard({super.key, required this.permissions});

  final PermissionsController permissions;

  @override
  Widget build(BuildContext context) {
    final p = permissions;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overlay Permission', style: titleStyle),
            const SizedBox(height: 4),
            _StatusLine(ok: p.overlayGranted),
            const SizedBox(height: 4),
            const Text(
              'MiniMe needs "Display over other apps" so your companion can walk '
              'onto the screen on top of whatever you are using.',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: p.overlayGranted ? null : p.openOverlaySettings,
              child: const Text('Grant Overlay Permission'),
            ),
            const Divider(height: 32),
            Text('For reliable reminders', style: titleStyle),
            const SizedBox(height: 8),
            _SetupRow(
              label: 'Exact alarms',
              ok: p.exactAlarmAllowed,
              actionLabel: 'Allow',
              onAction: p.openExactAlarmSettings,
            ),
            _SetupRow(
              label: 'Notifications (service status)',
              ok: p.notificationsGranted,
              actionLabel: 'Allow',
              onAction: p.requestNotifications,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: p.openBatterySettings,
                icon: const Icon(Icons.battery_saver),
                label: const Text('Battery optimization settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.ok});

  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: [
      TextSpan(text: '● ', style: TextStyle(color: ok ? Colors.green : Colors.red)),
      TextSpan(text: ok ? 'Granted' : 'Not Granted'),
    ]));
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({
    required this.label,
    required this.ok,
    required this.actionLabel,
    required this.onAction,
  });

  final String label;
  final bool ok;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('● ', style: TextStyle(color: ok ? Colors.green : Colors.orange)),
        Expanded(child: Text(label)),
        if (!ok) TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}
