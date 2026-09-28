# Monthly - Comprehensive System & Codebase Audit Bundle
> **Target Audience:** External LLMs (Claude 3.7 / GPT-4o / Gemini), Security Auditors, and Medical Software Reviewers.  
> **Package Scope:** Single self-contained architecture, mathematical prediction engine, database schemas, and Flutter client implementation.

---

## 1. System Vision & Non-Negotiable Constraints

**Monthly** is an open, privacy-first, on-device menstrual cycle tracking application built in Flutter.
- **Zero Cloud / Zero Network:** No analytics SDKs (Firebase, Mixpanel, Crashlytics). No remote server sync. No telemetry.
- **Zero Heavy ML / LLMs:** Prediction relies 100% on deterministic statistical mathematics (Weighted Moving Averages, Standard Deviation, biological phase offsets) running on the client CPU.
- **On-Device Storage:** SQLite (`sqflite`) with foreign key enforcement (`PRAGMA foreign_keys = ON;`), encrypted AES backup options, and biometric app locking.
- **Design Consistency:** Rounded corners (`BorderRadius.circular(16)` to `24`), accessible contrast ratios, 5-tab persistent bottom navigation (Today, Calendar, Insights, Learn, Me).

---

## 2. Core Mathematical Prediction Engine (`cycle_predictor.dart`)

```dart
import 'dart:math';

enum CyclePhase {
  menstrual,
  follicular,
  fertile,
  ovulation,
  luteal,
  predictedPeriod,
  none;

  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Period';
      case CyclePhase.follicular:
        return 'Follicular phase';
      case CyclePhase.fertile:
        return 'Fertile window';
      case CyclePhase.ovulation:
        return 'Ovulation day';
      case CyclePhase.luteal:
        return 'Luteal phase';
      case CyclePhase.predictedPeriod:
        return 'Predicted period';
      case CyclePhase.none:
        return 'Cycle day';
    }
  }

  String get chanceOfConception {
    switch (this) {
      case CyclePhase.ovulation:
        return 'Peak chance of conception';
      case CyclePhase.fertile:
        return 'High chance of conception';
      case CyclePhase.follicular:
        return 'Low chance of conception';
      case CyclePhase.menstrual:
      case CyclePhase.luteal:
      case CyclePhase.predictedPeriod:
      case CyclePhase.none:
        return 'Very low chance of conception';
    }
  }
}

class PredictionResult {
  final DateTime nextPeriodStartDate;
  final DateTime nextPeriodEndDate;
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final int predictedCycleLength;
  final int predictedPeriodLength;
  final int confidencePercent;
  final double cycleVariation; // standard deviation in days

  const PredictionResult({
    required this.nextPeriodStartDate,
    required this.nextPeriodEndDate,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.predictedCycleLength,
    required this.predictedPeriodLength,
    required this.confidencePercent,
    required this.cycleVariation,
  });
}

class DayStatus {
  final int cycleDay;
  final int totalCycleDays;
  final CyclePhase phase;
  final String chanceOfConception;
  final int daysUntilNextPeriod;

  const DayStatus({
    required this.cycleDay,
    required this.totalCycleDays,
    required this.phase,
    required this.chanceOfConception,
    required this.daysUntilNextPeriod,
  });
}

class CyclePredictor {
  /// Normalizes a DateTime to local midnight (00:00:00.000)
  static DateTime normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isDateInRange(DateTime target, DateTime start, DateTime end) {
    final t = normalizeDate(target);
    final s = normalizeDate(start);
    final e = normalizeDate(end);
    return !t.isBefore(s) && !t.isAfter(e);
  }

  /// Calculates statistical prediction for next cycle based on historical cycles
  static PredictionResult predictNextCycle({
    required List<Cycle> historicalCycles,
    required int defaultCycleLength,
    required int defaultPeriodLength,
    int lutealPhaseLength = 14,
  }) {
    // 1. Filter valid recorded past cycles (cycle length between 15 and 60 days)
    final validCycles = historicalCycles
        .where((c) => !c.isPredicted && c.cycleLength != null && c.cycleLength! >= 15 && c.cycleLength! <= 60)
        .toList();

    validCycles.sort((a, b) => a.startDate.compareTo(b.startDate));

    int predictedCycleLength;
    int predictedPeriodLength;
    double stdDev = 0.0;

    if (validCycles.length >= 3) {
      // Weighted Moving Average (most recent cycles have higher weights: 3, 2, 1)
      final n = validCycles.length;
      final c1 = validCycles[n - 1].cycleLength!;
      final c2 = validCycles[n - 2].cycleLength!;
      final c3 = validCycles[n - 3].cycleLength!;
      predictedCycleLength = ((3 * c1 + 2 * c2 + 1 * c3) / 6.0).round();

      // Standard deviation of historical cycles
      final lengths = validCycles.map((c) => c.cycleLength!.toDouble()).toList();
      final mean = lengths.reduce((a, b) => a + b) / lengths.length;
      final variance = lengths.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / lengths.length;
      stdDev = sqrt(variance);

      // Period duration average
      final validPeriods = validCycles.where((c) => c.periodLength != null && c.periodLength! > 0).map((c) => c.periodLength!).toList();
      if (validPeriods.isNotEmpty) {
        final lastFewPeriods = validPeriods.length > 3 ? validPeriods.sublist(validPeriods.length - 3) : validPeriods;
        predictedPeriodLength = (lastFewPeriods.reduce((a, b) => a + b) / lastFewPeriods.length).round();
      } else {
        predictedPeriodLength = defaultPeriodLength;
      }
    } else if (validCycles.isNotEmpty) {
      final total = validCycles.map((c) => c.cycleLength!).reduce((a, b) => a + b);
      predictedCycleLength = (total / validCycles.length).round();
      predictedPeriodLength = defaultPeriodLength;
      stdDev = 1.5;
    } else {
      predictedCycleLength = defaultCycleLength;
      predictedPeriodLength = defaultPeriodLength;
      stdDev = 2.0;
    }

    final rawStartDate = validCycles.isNotEmpty ? validCycles.last.startDate : DateTime.now();
    final lastStartDate = normalizeDate(rawStartDate);

    final nextPeriodStart = lastStartDate.add(Duration(days: predictedCycleLength));
    final nextPeriodEnd = nextPeriodStart.add(Duration(days: max(1, predictedPeriodLength - 1)));

    // Ovulation is predicted `lutealPhaseLength` days before next period start
    final ovulationDate = nextPeriodStart.subtract(Duration(days: lutealPhaseLength));

    // Fertile window: 5 days prior to ovulation through 1 day after
    final fertileStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileEnd = ovulationDate.add(const Duration(days: 1));

    // Confidence calculation (95% baseline penalized by stdDev)
    int confidence = (95 - (stdDev * 5)).round();
    if (confidence < 60) confidence = 60;
    if (confidence > 95) confidence = 95;

    return PredictionResult(
      nextPeriodStartDate: nextPeriodStart,
      nextPeriodEndDate: nextPeriodEnd,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      predictedCycleLength: predictedCycleLength,
      predictedPeriodLength: predictedPeriodLength,
      confidencePercent: confidence,
      cycleVariation: double.parse(stdDev.toStringAsFixed(1)),
    );
  }

  /// Calculates the day status for the active UI dial
  static DayStatus getDayStatus({
    required DateTime targetDate,
    required DateTime currentCycleStartDate,
    required PredictionResult prediction,
  }) {
    final start = normalizeDate(currentCycleStartDate);
    final target = normalizeDate(targetDate);
    final diff = target.difference(start).inDays;

    final cycleDay = diff + 1;
    final totalCycleDays = prediction.predictedCycleLength;
    final daysUntilNext = totalCycleDays - cycleDay;

    CyclePhase phase;
    if (cycleDay >= 1 && cycleDay <= prediction.predictedPeriodLength) {
      phase = CyclePhase.menstrual;
    } else {
      final ovulation = normalizeDate(prediction.ovulationDate);
      final fertileStart = normalizeDate(prediction.fertileWindowStart);
      final fertileEnd = normalizeDate(prediction.fertileWindowEnd);
      final nextStart = normalizeDate(prediction.nextPeriodStartDate);
      final nextEnd = normalizeDate(prediction.nextPeriodEndDate);

      if (isDateInRange(target, nextStart, nextEnd)) {
        phase = CyclePhase.predictedPeriod;
      } else if (isSameDay(target, ovulation)) {
        phase = CyclePhase.ovulation;
      } else if (isDateInRange(target, fertileStart, fertileEnd)) {
        phase = CyclePhase.fertile;
      } else if (target.isBefore(fertileStart)) {
        phase = CyclePhase.follicular;
      } else {
        phase = CyclePhase.luteal;
      }
    }

    return DayStatus(
      cycleDay: max(1, cycleDay),
      totalCycleDays: totalCycleDays,
      phase: phase,
      chanceOfConception: phase.chanceOfConception,
      daysUntilNextPeriod: max(0, daysUntilNext),
    );
  }

  /// Determines the visual phase of any given calendar date
  static CyclePhase getCalendarDatePhase({
    required DateTime date,
    required List<Cycle> cycles,
    required PredictionResult prediction,
  }) {
    final target = normalizeDate(date);

    for (final cycle in cycles) {
      final start = normalizeDate(cycle.startDate);
      final periodLength = cycle.periodLength ?? prediction.predictedPeriodLength;
      final end = start.add(Duration(days: max(1, periodLength - 1)));
      if (isDateInRange(target, start, end)) {
        return CyclePhase.menstrual;
      }
    }

    if (isDateInRange(target, prediction.nextPeriodStartDate, prediction.nextPeriodEndDate)) {
      return CyclePhase.predictedPeriod;
    }

    if (isSameDay(target, prediction.ovulationDate)) {
      return CyclePhase.ovulation;
    }

    if (isDateInRange(target, prediction.fertileWindowStart, prediction.fertileWindowEnd)) {
      return CyclePhase.fertile;
    }

    return CyclePhase.none;
  }
}
```

---

## 3. Database Schema & Data Models

### 3.1 SQLite DDL (`app_database.dart`)
```sql
PRAGMA foreign_keys = ON;

-- 1. User Settings
CREATE TABLE user_settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  default_cycle_length INTEGER NOT NULL DEFAULT 28,
  default_period_length INTEGER NOT NULL DEFAULT 5,
  luteal_phase_length INTEGER NOT NULL DEFAULT 14,
  is_biometric_enabled INTEGER NOT NULL DEFAULT 0,
  is_dark_mode INTEGER NOT NULL DEFAULT 0,
  period_reminders_enabled INTEGER NOT NULL DEFAULT 1,
  fertile_reminders_enabled INTEGER NOT NULL DEFAULT 1,
  onboarding_completed INTEGER NOT NULL DEFAULT 0
);

-- 2. Cycles Table
CREATE TABLE cycles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  start_date TEXT NOT NULL,
  end_date TEXT,
  cycle_length INTEGER,
  period_length INTEGER,
  is_predicted INTEGER NOT NULL DEFAULT 0,
  notes TEXT
);

-- 3. Daily Logs Table
CREATE TABLE daily_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL UNIQUE,
  flow_intensity TEXT,
  mood TEXT,
  pain_level INTEGER NOT NULL DEFAULT 0,
  energy_level INTEGER NOT NULL DEFAULT 3,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Daily Symptoms Table
CREATE TABLE daily_symptoms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  daily_log_id INTEGER NOT NULL REFERENCES daily_logs(id) ON DELETE CASCADE,
  symptom_key TEXT NOT NULL,
  severity INTEGER DEFAULT 1
);

-- 5. Daily Tracker Entries Table
CREATE TABLE tracker_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  daily_log_id INTEGER NOT NULL REFERENCES daily_logs(id) ON DELETE CASCADE,
  tracker_type TEXT NOT NULL,
  name TEXT NOT NULL,
  is_completed INTEGER NOT NULL DEFAULT 1,
  value TEXT
);
```

---

## 4. UI Architecture & Design Tokens

### 4.1 Color Tokens (`app_theme.dart`)
- **Primary:** `#F06292` (Pink 300)
- **Primary Light:** `#FCE4EC`
- **Period / Menstrual:** `#E91E63`
- **Predicted Period:** `#F48FB1`
- **Fertile Window:** `#7E57C2` (Purple)
- **Ovulation:** `#AB47BC`
- **Follicular / Luteal Base:** `#F06292`
- **Card Background:** `#FFFFFF`
- **Card Corner Radius:** `20.0px` - `24.0px`

### 4.2 Screens Overview
1. **Onboarding (`onboarding_screen.dart`):** Configures baseline cycle length, period length, and last period date into local DB.
2. **Today Screen (`today_screen.dart`):** Features custom canvas `CycleDial`, Next Period prediction card with confidence tag, Quick Daily Log button, and Symptoms chip list.
3. **Calendar Screen (`calendar_screen.dart`):** Month grid dynamically mapped to `CyclePhase` colors with legend (Period, Predicted, Fertile, Ovulation).
4. **Log Day Bottom Sheet (`log_day_sheet.dart`):** Flow selector (Light, Medium, Heavy, Spotting), Mood chips, Pain slider (0-5), Energy level, Custom symptoms, and Notes.
5. **Insights Screen (`insights_screen.dart`):** Cycle variations, average cycle length, period length, and visual history charts.
6. **Learn Screen (`learn_screen.dart`):** Built-in medical education articles on Menstrual Phases, Ovulation, and Irregular Cycles.
7. **Doctor Report Screen (`doctor_report_screen.dart`):** Generates exportable summary of cycles, symptoms, and pain for clinical consultations.
8. **Privacy & Security Screen (`privacy_security_screen.dart`):** Biometric toggle, 100% offline verification, and Encrypted Backup export/import.
9. **Reminders Screen (`reminders_screen.dart`):** Local system notification toggles for upcoming period and fertile window.

---

## 5. Verification & Unit Tests (`cycle_predictor_test.dart`)

```dart
void main() {
  group('CyclePredictor Tests', () {
    test('Fallback to baseline settings when no past cycles exist', () {
      final res = CyclePredictor.predictNextCycle(
        historicalCycles: [],
        defaultCycleLength: 28,
        defaultPeriodLength: 5,
      );
      expect(res.predictedCycleLength, 28);
      expect(res.predictedPeriodLength, 5);
      expect(res.confidencePercent, 85);
    });

    test('Computes weighted moving average with >= 3 historical cycles', () {
      final now = DateTime.now();
      final cycles = [
        Cycle(startDate: now.subtract(const Duration(days: 90)), cycleLength: 26, periodLength: 5),
        Cycle(startDate: now.subtract(const Duration(days: 62)), cycleLength: 28, periodLength: 5),
        Cycle(startDate: now.subtract(const Duration(days: 32)), cycleLength: 30, periodLength: 6),
      ];
      // Weights: (1*26 + 2*28 + 3*30) / 6 = (26 + 56 + 90) / 6 = 172 / 6 = 28.667 -> 29
      final res = CyclePredictor.predictNextCycle(
        historicalCycles: cycles,
        defaultCycleLength: 28,
        defaultPeriodLength: 5,
      );
      expect(res.predictedCycleLength, 29);
      expect(res.predictedPeriodLength, 5);
    });

    test('Detects correct cycle phases (Menstrual, Fertile, Ovulation, Luteal)', () {
      final cycleStart = DateTime(2026, 9, 1);
      final prediction = CyclePredictor.predictNextCycle(
        historicalCycles: [
          Cycle(startDate: cycleStart, cycleLength: 28, periodLength: 5),
        ],
        defaultCycleLength: 28,
        defaultPeriodLength: 5,
      );

      // Day 3: Menstrual
      final day3 = CyclePredictor.getDayStatus(
        targetDate: cycleStart.add(const Duration(days: 2)),
        currentCycleStartDate: cycleStart,
        prediction: prediction,
      );
      expect(day3.phase, CyclePhase.menstrual);

      // Ovulation: 14 days before next start (Day 15)
      final ovDate = prediction.ovulationDate;
      final ovStatus = CyclePredictor.getDayStatus(
        targetDate: ovDate,
        currentCycleStartDate: cycleStart,
        prediction: prediction,
      );
      expect(ovStatus.phase, CyclePhase.ovulation);
    });
  });
}
```

---

## 6. Prompt Template for Secondary LLM Audit (Claude / GPT-4o)

Copy and paste the prompt below along with this entire document to have another model audit the application:

```text
You are an expert mobile security auditor, bio-mathematical software analyst, and Senior Flutter architect.
Please perform a rigorous audit of the attached menstrual cycle tracking architecture ("Monthly").

Review specifically:
1. Mathematical Correctness: Evaluate the Weighted Moving Average, standard deviation calculation, ovulation timing (Knaus-Ogino offset / luteal phase assumption of 14 days), and calendar date boundary conditions (e.g. leap years, midnight normalization).
2. Privacy & Threat Model: Confirm whether the zero-telemetry and local SQLite model contains any accidental leak surfaces (clipboard, uncaught exceptions, system backups).
3. State Management & Database Integrity: Review Riverpod notifiers, foreign key cascading (`PRAGMA foreign_keys = ON`), and SQLite schema indices.
4. Edge Case Handling: Review how late periods (> predicted cycle length), short cycles (< 21 days), and long cycles (> 35 days) are handled.
5. Provide a prioritized list of any discovered bugs, risks, or performance recommendations.
```
