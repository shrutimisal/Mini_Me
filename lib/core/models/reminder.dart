enum RepeatType { daily, weekly, interval }

class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.message,
    required this.hour,
    required this.minute,
    this.repeat = RepeatType.daily,
    this.days = const {1, 2, 3, 4, 5, 6, 7},
    this.intervalHours = 2,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String message;
  final int hour;
  final int minute;
  final RepeatType repeat;

  /// ISO weekdays, 1 = Monday ... 7 = Sunday. Used when [repeat] is weekly.
  final Set<int> days;

  /// Used when [repeat] is interval: fires every N hours, anchored at hour:minute.
  final int intervalHours;
  final bool enabled;

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Reminder copyWith({
    String? title,
    String? message,
    int? hour,
    int? minute,
    RepeatType? repeat,
    Set<int>? days,
    int? intervalHours,
    bool? enabled,
  }) =>
      Reminder(
        id: id,
        title: title ?? this.title,
        message: message ?? this.message,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        repeat: repeat ?? this.repeat,
        days: days ?? this.days,
        intervalHours: intervalHours ?? this.intervalHours,
        enabled: enabled ?? this.enabled,
      );

  /// Returns a user-facing error, or null if the reminder is valid.
  String? validate() {
    if (title.trim().isEmpty) return 'Please enter a title.';
    if (title.trim().length > 40) return 'Title is too long (max 40 characters).';
    if (message.trim().isEmpty) return 'Please enter a message.';
    if (message.trim().length > 140) return 'Message is too long (max 140 characters).';
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return 'Invalid time.';
    if (repeat == RepeatType.weekly && days.isEmpty) return 'Pick at least one day.';
    if (repeat == RepeatType.interval && (intervalHours < 1 || intervalHours > 24)) {
      return 'Interval must be between 1 and 24 hours.';
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'hour': hour,
        'minute': minute,
        'repeat': repeat.name,
        'days': (days.toList()..sort()),
        'intervalHours': intervalHours,
        'enabled': enabled,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: (json['title'] as String?) ?? '',
        message: (json['message'] as String?) ?? '',
        hour: (json['hour'] as num).toInt(),
        minute: (json['minute'] as num).toInt(),
        repeat: RepeatType.values.firstWhere(
          (r) => r.name == json['repeat'],
          orElse: () => RepeatType.daily,
        ),
        days: ((json['days'] as List<dynamic>?) ?? const [1, 2, 3, 4, 5, 6, 7])
            .map((e) => (e as num).toInt())
            .toSet(),
        intervalHours: (json['intervalHours'] as num?)?.toInt() ?? 2,
        enabled: (json['enabled'] as bool?) ?? true,
      );
}
