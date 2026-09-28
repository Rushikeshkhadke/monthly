import 'package:flutter_test/flutter_test.dart';
import 'package:monthly/core/models/cycle.dart';
import 'package:monthly/core/models/daily_log.dart';
import 'package:monthly/core/math/cycle_predictor.dart';

void main() {
  group('CyclePredictor Tests', () {
    test('Fallback to baseline settings when no past cycles exist', () {
      final prediction = CyclePredictor.predictNextCycle(
        historicalCycles: [],
        defaultCycleLength: 28,
        defaultPeriodLength: 5,
      );

      expect(prediction.predictedCycleLength, equals(28));
      expect(prediction.predictedPeriodLength, equals(5));
      expect(prediction.confidencePercent, inInclusiveRange(60, 95));
    });

    test('Computes weighted moving average with >= 3 historical cycles', () {
      final now = DateTime(2026, 9, 1);
      final cycles = [
        Cycle(startDate: now.subtract(const Duration(days: 84)), cycleLength: 28, periodLength: 5),
        Cycle(startDate: now.subtract(const Duration(days: 56)), cycleLength: 30, periodLength: 5),
        Cycle(startDate: now.subtract(const Duration(days: 26)), cycleLength: 26, periodLength: 4),
      ];

      // Weighted average: (3 * 26 + 2 * 30 + 1 * 28) / 6 = (78 + 60 + 28) / 6 = 166 / 6 = 27.67 -> rounds to 28
      final prediction = CyclePredictor.predictNextCycle(
        historicalCycles: cycles,
        defaultCycleLength: 28,
        defaultPeriodLength: 5,
      );

      expect(prediction.predictedCycleLength, equals(28));
      expect(prediction.ovulationDate, equals(prediction.nextPeriodStartDate.subtract(const Duration(days: 14))));
      expect(prediction.fertileWindowStart, equals(prediction.ovulationDate.subtract(const Duration(days: 5))));
      expect(prediction.fertileWindowEnd, equals(prediction.ovulationDate.add(const Duration(days: 1))));
    });

    test('Detects correct cycle phases (Menstrual, Fertile, Ovulation, Luteal, Late)', () {
      final start = DateTime(2026, 9, 1);
      final prediction = CyclePredictor.predictNextCycle(
        historicalCycles: [
          Cycle(startDate: start, cycleLength: 28, periodLength: 5),
        ],
        defaultCycleLength: 28,
        defaultPeriodLength: 5,
      );

      // Day 2 should be Menstrual
      final day2Status = CyclePredictor.getDayStatus(
        targetDate: start.add(const Duration(days: 1)),
        currentCycleStartDate: start,
        prediction: prediction,
      );
      expect(day2Status.phase, equals(CyclePhase.menstrual));
      expect(day2Status.cycleDay, equals(2));

      // Ovulation day status (typically day 14 in 28-day cycle)
      final ovulationStatus = CyclePredictor.getDayStatus(
        targetDate: prediction.ovulationDate,
        currentCycleStartDate: start,
        prediction: prediction,
      );
      expect(ovulationStatus.phase, equals(CyclePhase.ovulation));
      expect(ovulationStatus.chanceOfConception, contains('Peak'));

      // Day 35 should be Late / Overdue
      final day35Status = CyclePredictor.getDayStatus(
        targetDate: start.add(const Duration(days: 34)),
        currentCycleStartDate: start,
        prediction: prediction,
      );
      expect(day35Status.phase, equals(CyclePhase.late));
      expect(day35Status.phase.displayName, contains('overdue'));
    });

    test('DailyLog preserves trackers (medication, supplements, workout)', () {
      final log = DailyLog(
        logDate: DateTime(2026, 9, 28),
        flow: FlowIntensity.medium,
        mood: MoodType.calm,
        painLevel: 2,
        energyLevel: 4,
        medication: true,
        supplements: true,
        workout: true,
        symptoms: ['Cramps', 'Headache'],
        notes: 'Felt good after pilates',
      );

      final map = log.toMap();
      expect(map['medication'], equals(1));
      expect(map['supplements'], equals(1));
      expect(map['workout'], equals(1));

      final restored = DailyLog.fromMap(map, symptoms: ['Cramps', 'Headache']);
      expect(restored.medication, isTrue);
      expect(restored.supplements, isTrue);
      expect(restored.workout, isTrue);
      expect(restored.painLevel, equals(2));
      expect(restored.energyLevel, equals(4));
    });
  });
}
