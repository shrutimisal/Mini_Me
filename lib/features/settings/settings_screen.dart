import 'package:flutter/material.dart';

import '../../core/models/app_settings.dart';
import '../../core/services/app_services.dart';
import '../../shared/extensions/time_extensions.dart';
import '../../shared/helpers/snackbar.dart';
import '../overlay/overlay_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppServices.instance.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final s = controller.value;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SliderTile(
                label: 'Avatar size',
                valueLabel: '${(s.avatarScale * 100).round()}%',
                value: s.avatarScale,
                min: 0.6,
                max: 1.6,
                onChanged: (v) => controller.preview(s.copyWith(avatarScale: v)),
                onChangeEnd: (_) => controller.save(),
              ),
              _SliderTile(
                label: 'Message duration',
                valueLabel: '${s.durationSeconds} s',
                value: s.durationSeconds.toDouble(),
                min: 2,
                max: 20,
                divisions: 18,
                onChanged: (v) => controller.preview(s.copyWith(durationSeconds: v.round())),
                onChangeEnd: (_) => controller.save(),
              ),
              _SliderTile(
                label: 'Animation duration',
                valueLabel: '${s.animationMs} ms',
                value: s.animationMs.toDouble(),
                min: 200,
                max: 2000,
                divisions: 18,
                onChanged: (v) => controller.preview(s.copyWith(animationMs: v.round())),
                onChangeEnd: (_) => controller.save(),
              ),
              const SizedBox(height: 8),
              Text('Overlay position', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<OverlayPosition>(
                segments: const [
                  ButtonSegment(value: OverlayPosition.top, label: Text('Top')),
                  ButtonSegment(value: OverlayPosition.center, label: Text('Middle')),
                  ButtonSegment(value: OverlayPosition.bottom, label: Text('Bottom')),
                ],
                selected: {s.position},
                onSelectionChanged: (sel) => controller.update(s.copyWith(position: sel.first)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sound'),
                subtitle: const Text('Play the default notification sound when MiniMe appears'),
                value: s.soundEnabled,
                onChanged: (v) => controller.update(s.copyWith(soundEnabled: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Quiet hours'),
                subtitle: const Text('Scheduled reminders will not appear during this time'),
                value: s.quietEnabled,
                onChanged: (v) => controller.update(s.copyWith(quietEnabled: v)),
              ),
              if (s.quietEnabled)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(
                              context: context, initialTime: s.quietStartMinutes.toTimeOfDay());
                          if (t != null) controller.update(s.copyWith(quietStartMinutes: t.totalMinutes));
                        },
                        child: Text('From ${s.quietStartMinutes.toTimeOfDay().format(context)}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(
                              context: context, initialTime: s.quietEndMinutes.toTimeOfDay());
                          if (t != null) controller.update(s.copyWith(quietEndMinutes: t.totalMinutes));
                        },
                        child: Text('Until ${s.quietEndMinutes.toTimeOfDay().format(context)}'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () async {
                  final result = await AppServices.instance.overlay.show();
                  if (result != OverlayResult.ok && context.mounted) {
                    showMessage(context, 'Grant overlay permission on the home screen first.');
                  }
                },
                child: const Text('Preview with these settings'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
    this.divisions,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            Text(valueLabel),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
