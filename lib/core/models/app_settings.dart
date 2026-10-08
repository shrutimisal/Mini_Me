enum OverlayPosition { top, center, bottom }

class AppSettings {
  const AppSettings({
    this.avatarScale = 1.0,
    this.durationSeconds = 5,
    this.animationMs = 700,
    this.soundEnabled = false,
    this.quietEnabled = false,
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
    this.position = OverlayPosition.center,
  });

  final double avatarScale;
  final int durationSeconds;
  final int animationMs;
  final bool soundEnabled;
  final bool quietEnabled;
  final int quietStartMinutes;
  final int quietEndMinutes;
  final OverlayPosition position;

  AppSettings copyWith({
    double? avatarScale,
    int? durationSeconds,
    int? animationMs,
    bool? soundEnabled,
    bool? quietEnabled,
    int? quietStartMinutes,
    int? quietEndMinutes,
    OverlayPosition? position,
  }) =>
      AppSettings(
        avatarScale: avatarScale ?? this.avatarScale,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        animationMs: animationMs ?? this.animationMs,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        quietEnabled: quietEnabled ?? this.quietEnabled,
        quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
        quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
        position: position ?? this.position,
      );

  /// Keys must match OverlaySettings.fromJson in Kotlin.
  Map<String, dynamic> toJson() => {
        'avatarScale': avatarScale,
        'durationMs': durationSeconds * 1000,
        'animationMs': animationMs,
        'sound': soundEnabled,
        'quietEnabled': quietEnabled,
        'quietStartMin': quietStartMinutes,
        'quietEndMin': quietEndMinutes,
        'position': position.name,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const d = AppSettings();
    return AppSettings(
      avatarScale: ((json['avatarScale'] as num?)?.toDouble() ?? d.avatarScale).clamp(0.6, 2.0).toDouble(),
      durationSeconds:
          ((((json['durationMs'] as num?)?.toInt() ?? 5000) / 1000).round()).clamp(1, 60).toInt(),
      animationMs: ((json['animationMs'] as num?)?.toInt() ?? d.animationMs).clamp(100, 3000).toInt(),
      soundEnabled: (json['sound'] as bool?) ?? d.soundEnabled,
      quietEnabled: (json['quietEnabled'] as bool?) ?? d.quietEnabled,
      quietStartMinutes:
          ((json['quietStartMin'] as num?)?.toInt() ?? d.quietStartMinutes).clamp(0, 1439).toInt(),
      quietEndMinutes:
          ((json['quietEndMin'] as num?)?.toInt() ?? d.quietEndMinutes).clamp(0, 1439).toInt(),
      position: OverlayPosition.values.firstWhere(
        (p) => p.name == json['position'],
        orElse: () => d.position,
      ),
    );
  }
}
