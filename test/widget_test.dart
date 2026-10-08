import 'package:flutter_test/flutter_test.dart';
import 'package:mini_me/core/models/app_settings.dart';
import 'package:mini_me/core/models/reminder.dart';

void main() {
  test('Reminder JSON round trip', () {
    const r = Reminder(
      id: '1',
      title: 'Study',
      message: 'Hit the books 📚',
      hour: 19,
      minute: 30,
      repeat: RepeatType.weekly,
      days: {1, 2, 3, 4, 5},
      enabled: false,
    );
    final back = Reminder.fromJson(r.toJson());
    expect(back.title, 'Study');
    expect(back.hour, 19);
    expect(back.minute, 30);
    expect(back.repeat, RepeatType.weekly);
    expect(back.days, {1, 2, 3, 4, 5});
    expect(back.enabled, false);
  });

  test('Reminder validation', () {
    const bad = Reminder(id: '1', title: ' ', message: 'x', hour: 1, minute: 0);
    expect(bad.validate(), isNotNull);
    const noDays = Reminder(
        id: '1', title: 'a', message: 'b', hour: 1, minute: 0, repeat: RepeatType.weekly, days: {});
    expect(noDays.validate(), isNotNull);
    const ok = Reminder(id: '1', title: 'a', message: 'b', hour: 1, minute: 0);
    expect(ok.validate(), isNull);
  });

  test('AppSettings JSON round trip and clamping', () {
    const s = AppSettings(durationSeconds: 8, position: OverlayPosition.bottom, soundEnabled: true);
    final back = AppSettings.fromJson(s.toJson());
    expect(back.durationSeconds, 8);
    expect(back.position, OverlayPosition.bottom);
    expect(back.soundEnabled, true);
    expect(AppSettings.fromJson({'animationMs': 999999}).animationMs, 3000);
  });
}
