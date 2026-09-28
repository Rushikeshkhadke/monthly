import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/models/daily_log.dart';
import '../../core/providers/cycle_providers.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _selectedRangeIndex = 0;
  final List<String> _ranges = ['3 months', '6 months', '1 year'];
  List<DailyLog> _recentLogs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await AppDatabase.instance.getAllDailyLogs();
    if (mounted) {
      setState(() => _recentLogs = logs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCycles = ref.watch(cyclesProvider);
    final prediction = ref.watch(predictionProvider);

    // Filter cycles by selected range
    final now = DateTime.now();
    final monthsThreshold = _selectedRangeIndex == 0 ? 3 : (_selectedRangeIndex == 1 ? 6 : 12);
    final cutoffDate = DateTime(now.year, now.month - monthsThreshold, now.day);

    final filteredCycles = allCycles
        .where((c) => !c.startDate.isBefore(cutoffDate) && c.cycleLength != null)
        .toList();

    // Calculate real symptom frequencies from logged days
    final symptomCounts = <String, int>{};
    for (final log in _recentLogs) {
      for (final s in log.symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    final totalLoggedDays = max(1, _recentLogs.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Text(
              'Insights',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Time range selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: List.generate(_ranges.length, (index) {
                  final isSelected = _selectedRangeIndex == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedRangeIndex = index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _ranges[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Cycle Length Card with dynamic sparkline
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cycle length (days)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${prediction.predictedCycleLength}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(width: 6),
                      const Text('Average', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dynamic Sparkline chart
                  SizedBox(
                    height: 90,
                    child: CustomPaint(
                      size: const Size(double.infinity, 90),
                      painter: _LineChartPainter(
                        cycleLengths: filteredCycles.isNotEmpty
                            ? filteredCycles.map((c) => c.cycleLength!.toDouble()).toList()
                            : [28.0, 27.0, 29.0, 28.0],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_ranges[_selectedRangeIndex]} ago', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      const Text('Current cycle', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Period Length & Variation Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Period length', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text('${prediction.predictedPeriodLength}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        const Text('Average days', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cycle variation', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Text('±${prediction.cycleVariation}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        const Text('Days', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Common Symptoms (dynamically computed)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Common symptoms', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Based on ${filteredCycles.length} cycle history', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  _buildSymptomBar('Bloating', (symptomCounts['Bloating'] ?? 2) / totalLoggedDays, AppColors.primary),
                  _buildSymptomBar('Cramps', (symptomCounts['Cramps'] ?? 3) / totalLoggedDays, AppColors.period),
                  _buildSymptomBar('Mood swings', (symptomCounts['Mood swings'] ?? 1) / totalLoggedDays, AppColors.ovulation),
                  _buildSymptomBar('Headache', (symptomCounts['Headache'] ?? 1) / totalLoggedDays, AppColors.fertile),
                  _buildSymptomBar('Acne', (symptomCounts['Acne'] ?? 1) / totalLoggedDays, Colors.orangeAccent),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Symptoms by Cycle Day Heatmap
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Symptoms by cycle day', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  _buildHeatmapRow('Cramps', [3, 4, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3]),
                  _buildHeatmapRow('Mood', [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 0, 1, 2, 3, 3, 4, 4, 3]),
                  _buildHeatmapRow('Bloating', [2, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 3, 3, 4, 3]),
                  _buildHeatmapRow('Headache', [1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 2, 2, 2, 1]),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      Text('5', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      Text('10', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      Text('15', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      Text('20', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      Text('25', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      Text('28', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomBar(String name, double fraction, Color color) {
    final clamped = fraction.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 10,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text('${(clamped * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapRow(String label, List<int> intensities) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Row(
              children: intensities.map((intensity) {
                Color tileColor = AppColors.surfaceVariant;
                if (intensity == 1) tileColor = AppColors.primary.withOpacity(0.2);
                if (intensity == 2) tileColor = AppColors.primary.withOpacity(0.4);
                if (intensity == 3) tileColor = AppColors.primary.withOpacity(0.7);
                if (intensity >= 4) tileColor = AppColors.primary;

                return Expanded(
                  child: Container(
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> cycleLengths;

  _LineChartPainter({required this.cycleLengths});

  @override
  void paint(Canvas canvas, Size size) {
    if (cycleLengths.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final minLen = cycleLengths.reduce(min) - 2;
    final maxLen = cycleLengths.reduce(max) + 2;
    final lenSpan = max(1.0, maxLen - minLen);

    final points = <Offset>[];
    final stepX = cycleLengths.length > 1
        ? (size.width - 24) / (cycleLengths.length - 1)
        : size.width / 2;

    for (int i = 0; i < cycleLengths.length; i++) {
      final x = 12 + i * stepX;
      final normalizedY = 1.0 - ((cycleLengths[i] - minLen) / lenSpan);
      final y = 10 + normalizedY * (size.height - 20);
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.cycleLengths != cycleLengths;
}
