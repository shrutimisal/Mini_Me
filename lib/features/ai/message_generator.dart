import '../../core/models/reminder.dart';

/// Placeholder for the future AI layer. Core reminders never depend on it:
/// if generation fails or is offline, fall back to [Reminder.message].
/// Do not embed API keys in the app; call your own backend instead.
abstract interface class MessageGenerator {
  Future<String> generate(Reminder reminder);
}

class StaticMessageGenerator implements MessageGenerator {
  const StaticMessageGenerator();

  @override
  Future<String> generate(Reminder reminder) async => reminder.message;
}
