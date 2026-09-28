import 'dart:math';
import '../models/cycle.dart';

enum CyclePhase {
  menstrual,
  follicular,
  fertile,
  ovulation,
  luteal,
  predictedPeriod,
  late,
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
      case CyclePhase.late:
        return 'Period overdue';
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
      case CyclePhase.late:
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

  /// Calculates statistical prediction for the next cycle based on historical cycles
  /// and user baseline settings.
  static PredictionResult predictNextCycle({
    required List<Cycle> historicalCycles,
    required int defaultCycleLength,
    required int defaultPeriodLength,
    int lutealPhaseLength = 14,
  }) {
    // Filter valid recorded past cycles (non-predicted with a cycle length)
    final validCycles = historicalCycles
        .where((c) => !c.isPredicted && c.cycleLength != null && c.cycleLength! >= 15 && c.cycleLength! <= 60)
        .toList();

    // Sort chronologically ascending
    validCycles.sort((a, b) => a.startDate.compareTo(b.startDate));

    int predictedCycleLength;
    int predictedPeriodLength;
    double stdDev = 0.0;

    if (validCycles.length >= 3) {
      // 1. Weighted Moving Average (most recent cycles have higher weights: 3, 2, 1)
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
      // Simple average when fewer than 3 recorded cycles
      final total = validCycles.map((c) => c.cycleLength!).reduce((a, b) => a + b);
      predictedCycleLength = (total / validCycles.length).round();
      predictedPeriodLength = defaultPeriodLength;
      stdDev = 1.5;
    } else {
      // Fallback to baseline settings
      predictedCycleLength = defaultCycleLength;
      predictedPeriodLength = defaultPeriodLength;
      stdDev = 2.0;
    }

    // Determine the reference start date (last recorded cycle or today)
    final rawStartDate = validCycles.isNotEmpty ? validCycles.last.startDate : DateTime.now();
    final lastStartDate = normalizeDate(rawStartDate);

    final nextPeriodStart = lastStartDate.add(Duration(days: predictedCycleLength));
    final nextPeriodEnd = nextPeriodStart.add(Duration(days: max(1, predictedPeriodLength - 1)));

    // Ovulation is predicted `lutealPhaseLength` days before next period start
    final ovulationDate = nextPeriodStart.subtract(Duration(days: lutealPhaseLength));

    // Fertile window: 5 days prior to ovulation through 1 day after
    final fertileStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileEnd = ovulationDate.add(const Duration(days: 1));

    // Confidence score: 95% baseline minus penalties for variance
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

  /// Calculates the day status (e.g. Day 14, phase, conception chance) for a specific target date
  static DayStatus getDayStatus({
    required DateTime targetDate,
    required DateTime currentCycleStartDate,
    required PredictionResult prediction,
  }) {
    final start = normalizeDate(currentCycleStartDate);
    final target = normalizeDate(targetDate);
    final diff = target.difference(start).inDays;

    final cycleDay = diff + 1; // 1-indexed (Day 1, Day 2...)
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

      if (target.isAfter(nextEnd)) {
        phase = CyclePhase.late;
      } else if (isDateInRange(target, nextStart, nextEnd)) {
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

  /// Determines the visual phase of any given calendar date based on recorded cycles and predictions
  static CyclePhase getCalendarDatePhase({
    required DateTime date,
    required List<Cycle> cycles,
    required PredictionResult prediction,
  }) {
    final target = normalizeDate(date);

    // 1. Check if it falls within any actual recorded past period bleed
    for (final cycle in cycles) {
      final start = normalizeDate(cycle.startDate);
      final periodLength = cycle.periodLength ?? prediction.predictedPeriodLength;
      final end = start.add(Duration(days: max(1, periodLength - 1)));
      if (isDateInRange(target, start, end)) {
        return CyclePhase.menstrual;
      }
    }

    // 2. Check if it falls in the upcoming predicted period
    if (isDateInRange(target, prediction.nextPeriodStartDate, prediction.nextPeriodEndDate)) {
      return CyclePhase.predictedPeriod;
    }

    // 3. Check ovulation day
    if (isSameDay(target, prediction.ovulationDate)) {
      return CyclePhase.ovulation;
    }

    // 4. Check fertile window
    if (isDateInRange(target, prediction.fertileWindowStart, prediction.fertileWindowEnd)) {
      return CyclePhase.fertile;
    }

    return CyclePhase.none;
  }
}
