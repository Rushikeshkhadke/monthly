import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../math/cycle_predictor.dart';
import '../models/cycle.dart';
import '../models/daily_log.dart';
import '../models/user_settings.dart';

// User Settings Provider
class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(const UserSettings()) {
    _load();
  }

  Future<void> _load() async {
    final settings = await AppDatabase.instance.getSettings();
    state = settings;
  }

  Future<void> update(UserSettings newSettings) async {
    await AppDatabase.instance.updateSettings(newSettings);
    state = newSettings;
  }

  Future<void> completeOnboarding({
    required int cycleLength,
    required int periodLength,
    required DateTime lastPeriodDate,
  }) async {
    final updated = state.copyWith(
      defaultCycleLength: cycleLength,
      defaultPeriodLength: periodLength,
      onboardingCompleted: true,
    );
    await AppDatabase.instance.updateSettings(updated);

    // Record the first historical cycle
    final initialCycle = Cycle(
      startDate: lastPeriodDate,
      periodLength: periodLength,
      cycleLength: cycleLength,
    );
    await AppDatabase.instance.insertCycle(initialCycle);

    state = updated;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});

// Cycles List Provider
class CyclesNotifier extends StateNotifier<List<Cycle>> {
  CyclesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final list = await AppDatabase.instance.getAllCycles();
    state = list;
  }

  Future<void> addCycle(Cycle cycle) async {
    await AppDatabase.instance.insertCycle(cycle);
    await _load();
  }

  Future<void> refresh() async => await _load();
}

final cyclesProvider = StateNotifierProvider<CyclesNotifier, List<Cycle>>((ref) {
  return CyclesNotifier();
});

// Daily Logs Provider (Date string 'YYYY-MM-DD' -> DailyLog)
class DailyLogsNotifier extends StateNotifier<Map<String, DailyLog>> {
  DailyLogsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final logs = await AppDatabase.instance.getAllDailyLogs();
    final map = <String, DailyLog>{};
    for (final l in logs) {
      final key = l.logDate.toIso8601String().split('T').first;
      map[key] = l;
    }
    state = map;
  }

  Future<void> refresh() async => await _load();
}

final dailyLogsProvider = StateNotifierProvider<DailyLogsNotifier, Map<String, DailyLog>>((ref) {
  return DailyLogsNotifier();
});

// Statistical Prediction Provider
final predictionProvider = Provider<PredictionResult>((ref) {
  final cycles = ref.watch(cyclesProvider);
  final settings = ref.watch(settingsProvider);

  return CyclePredictor.predictNextCycle(
    historicalCycles: cycles,
    defaultCycleLength: settings.defaultCycleLength,
    defaultPeriodLength: settings.defaultPeriodLength,
    lutealPhaseLength: settings.lutealPhaseLength,
  );
});

// Day Status Provider (for today or selected date)
final todayStatusProvider = Provider<DayStatus>((ref) {
  final cycles = ref.watch(cyclesProvider);
  final prediction = ref.watch(predictionProvider);

  final lastCycleStart = cycles.isNotEmpty ? cycles.last.startDate : DateTime.now().subtract(const Duration(days: 13));

  return CyclePredictor.getDayStatus(
    targetDate: DateTime.now(),
    currentCycleStartDate: lastCycleStart,
    prediction: prediction,
  );
});
