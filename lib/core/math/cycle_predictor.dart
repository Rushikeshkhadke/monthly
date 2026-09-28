import 'dart:math';
import '../models/cycle.dart';

enum CyclePhase {
  menstrual,
  follicular,
  fertile,
  ovulation,
  luteal;

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
    final lastStartDate = validCycles.isNotEmpty ? validCycles.last.startDate : DateTime.now();

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
    final start = DateTime(currentCycleStartDate.year, currentCycleStartDate.month, currentCycleStartDate.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final diff = target.difference(start).inDays;

    final cycleDay = diff + 1; // 1-indexed (Day 1, Day 2...)
    final totalCycleDays = prediction.predictedCycleLength;
    final daysUntilNext = totalCycleDays - cycleDay;

    CyclePhase phase;
    if (cycleDay <= prediction.predictedPeriodLength) {
      phase = CyclePhase.menstrual;
    } else {
      final ovulation = DateTime(prediction.ovulationDate.year, prediction.ovulationDate.month, prediction.ovulationDate.day);
      final fertileStart = DateTime(prediction.fertileWindowStart.year, prediction.fertileWindowStart.month, prediction.fertileWindowStart.day);
      final fertileEnd = DateTime(prediction.fertileWindowEnd.year, prediction.fertileWindowEnd.month, prediction.fertileWindowEnd.day);

      if (target.isAtSameMomentAs(ovulation)) {
        phase = CyclePhase.ovulation;
      } else if (!target.isBefore(fertileStart) && !target.isAfter(fertileEnd)) {
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
}
