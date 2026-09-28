class UserSettings {
  final int? id;
  final int defaultCycleLength; // default 28
  final int defaultPeriodLength; // default 5
  final int lutealPhaseLength; // default 14
  final bool appLockEnabled;
  final String? pinHash;
  final bool biometricEnabled;
  final bool disguiseModeEnabled;
  final bool panicHideEnabled;
  final bool notificationsEnabled;
  final int periodReminderDaysBefore; // default 3
  final String dailyLogReminderTime; // '21:00'
  final String themeMode; // 'system', 'light', 'dark'
  final bool onboardingCompleted;

  const UserSettings({
    this.id,
    this.defaultCycleLength = 28,
    this.defaultPeriodLength = 5,
    this.lutealPhaseLength = 14,
    this.appLockEnabled = false,
    this.pinHash,
    this.biometricEnabled = false,
    this.disguiseModeEnabled = false,
    this.panicHideEnabled = true,
    this.notificationsEnabled = true,
    this.periodReminderDaysBefore = 3,
    this.dailyLogReminderTime = '21:00',
    this.themeMode = 'system',
    this.onboardingCompleted = false,
  });

  UserSettings copyWith({
    int? id,
    int? defaultCycleLength,
    int? defaultPeriodLength,
    int? lutealPhaseLength,
    bool? appLockEnabled,
    String? pinHash,
    bool? biometricEnabled,
    bool? disguiseModeEnabled,
    bool? panicHideEnabled,
    bool? notificationsEnabled,
    int? periodReminderDaysBefore,
    String? dailyLogReminderTime,
    String? themeMode,
    bool? onboardingCompleted,
  }) {
    return UserSettings(
      id: id ?? this.id,
      defaultCycleLength: defaultCycleLength ?? this.defaultCycleLength,
      defaultPeriodLength: defaultPeriodLength ?? this.defaultPeriodLength,
      lutealPhaseLength: lutealPhaseLength ?? this.lutealPhaseLength,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      pinHash: pinHash ?? this.pinHash,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      disguiseModeEnabled: disguiseModeEnabled ?? this.disguiseModeEnabled,
      panicHideEnabled: panicHideEnabled ?? this.panicHideEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      periodReminderDaysBefore: periodReminderDaysBefore ?? this.periodReminderDaysBefore,
      dailyLogReminderTime: dailyLogReminderTime ?? this.dailyLogReminderTime,
      themeMode: themeMode ?? this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'default_cycle_length': defaultCycleLength,
      'default_period_length': defaultPeriodLength,
      'luteal_phase_length': lutealPhaseLength,
      'app_lock_enabled': appLockEnabled ? 1 : 0,
      'pin_hash': pinHash,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'disguise_mode_enabled': disguiseModeEnabled ? 1 : 0,
      'panic_hide_enabled': panicHideEnabled ? 1 : 0,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'period_reminder_days_before': periodReminderDaysBefore,
      'daily_log_reminder_time': dailyLogReminderTime,
      'theme_mode': themeMode,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as int?,
      defaultCycleLength: map['default_cycle_length'] as int? ?? 28,
      defaultPeriodLength: map['default_period_length'] as int? ?? 5,
      lutealPhaseLength: map['luteal_phase_length'] as int? ?? 14,
      appLockEnabled: (map['app_lock_enabled'] as int? ?? 0) == 1,
      pinHash: map['pin_hash'] as String?,
      biometricEnabled: (map['biometric_enabled'] as int? ?? 0) == 1,
      disguiseModeEnabled: (map['disguise_mode_enabled'] as int? ?? 0) == 1,
      panicHideEnabled: (map['panic_hide_enabled'] as int? ?? 1) == 1,
      notificationsEnabled: (map['notifications_enabled'] as int? ?? 1) == 1,
      periodReminderDaysBefore: map['period_reminder_days_before'] as int? ?? 3,
      dailyLogReminderTime: map['daily_log_reminder_time'] as String? ?? '21:00',
      themeMode: map['theme_mode'] as String? ?? 'system',
      onboardingCompleted: (map['onboarding_completed'] as int? ?? 0) == 1,
    );
  }
}
