import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/math/cycle_predictor.dart';

class CycleDial extends StatelessWidget {
  final DayStatus dayStatus;
  final PredictionResult prediction;

  const CycleDial({
    super.key,
    required this.dayStatus,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: _CycleDialPainter(
              dayStatus: dayStatus,
              prediction: prediction,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Day ${dayStatus.cycleDay}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPhaseColor(dayStatus.phase).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dayStatus.phase.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getPhaseColor(dayStatus.phase),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dayStatus.chanceOfConception,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return AppColors.period;
      case CyclePhase.predictedPeriod:
        return AppColors.predicted;
      case CyclePhase.fertile:
        return AppColors.fertile;
      case CyclePhase.ovulation:
        return AppColors.ovulation;
      case CyclePhase.late:
        return Colors.deepOrangeAccent;
      case CyclePhase.follicular:
      case CyclePhase.luteal:
      case CyclePhase.none:
        return AppColors.primary;
    }
  }
}

class _CycleDialPainter extends CustomPainter {
  final DayStatus dayStatus;
  final PredictionResult prediction;

  _CycleDialPainter({
    required this.dayStatus,
    required this.prediction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    const strokeWidth = 18.0;

    final backgroundPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Base background track
    canvas.drawCircle(center, radius, backgroundPaint);

    // Colored phase segments
    final totalDays = max(1, dayStatus.totalCycleDays);
    const startAngle = -pi / 2; // top of circle

    // Draw period phase arc
    final periodSweep = (prediction.predictedPeriodLength / totalDays) * 2 * pi;
    final periodPaint = Paint()
      ..color = AppColors.period.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, periodSweep, false, periodPaint);

    // Draw fertile window arc (dynamic sweep based on totalDays)
    final fertileDaysStart = max(0, totalDays - 14 - 5);
    final fertileStartAngle = startAngle + (fertileDaysStart / totalDays) * 2 * pi;
    final fertileSweep = (6 / totalDays) * 2 * pi;
    final fertilePaint = Paint()
      ..color = AppColors.fertile
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), fertileStartAngle, fertileSweep, false, fertilePaint);

    // Draw current progress indicator tick/dot
    final progressFraction = min(1.0, (dayStatus.cycleDay - 1) / totalDays);
    final currentDayAngle = startAngle + progressFraction * 2 * pi;
    final dotX = center.dx + radius * cos(currentDayAngle);
    final dotY = center.dy + radius * sin(currentDayAngle);

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotFillPaint = Paint()
      ..color = dayStatus.phase == CyclePhase.late ? Colors.deepOrangeAccent : AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 3, dotBorderPaint);
    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2, dotFillPaint);
  }

  @override
  bool shouldRepaint(covariant _CycleDialPainter oldDelegate) => true;
}
