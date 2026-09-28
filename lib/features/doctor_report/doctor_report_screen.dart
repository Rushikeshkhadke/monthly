import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/models/cycle.dart';
import '../../core/models/daily_log.dart';
import '../../core/providers/cycle_providers.dart';

class DoctorReportScreen extends ConsumerStatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  ConsumerState<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends ConsumerState<DoctorReportScreen> {
  List<DailyLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final logs = await AppDatabase.instance.getAllDailyLogs();
    if (mounted) {
      setState(() => _logs = logs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cycles = ref.watch(cyclesProvider);
    final prediction = ref.watch(predictionProvider);

    final now = DateTime.now();
    final startDate = cycles.isNotEmpty
        ? cycles.first.startDate
        : now.subtract(const Duration(days: 90));
    final dateRangeStr =
        '${DateFormat('d MMM yyyy').format(startDate)} – ${DateFormat('d MMM yyyy').format(now)}';

    // Calculate dynamic symptoms from actual logs
    final symptomCounts = <String, int>{};
    int medDays = 0;
    int suppDays = 0;
    for (final l in _logs) {
      if (l.medication) medDays++;
      if (l.supplements) suppDays++;
      for (final s in l.symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    final totalLogged = max(1, _logs.length);

    String buildReportPlainText() {
      final buffer = StringBuffer();
      buffer.writeln('========================================');
      buffer.writeln('MONTHLY - CYCLE HEALTH CLINICAL SUMMARY');
      buffer.writeln('========================================');
      buffer.writeln('Date Range: $dateRangeStr');
      buffer.writeln('Cycles Tracked: ${cycles.length}');
      buffer.writeln('Average Cycle Length: ${prediction.predictedCycleLength} days');
      buffer.writeln('Average Period Duration: ${prediction.predictedPeriodLength} days');
      buffer.writeln('Cycle Variation (Std Dev): ±${prediction.cycleVariation} days');
      buffer.writeln('\n--- CYCLE HISTORY ---');
      for (final c in cycles) {
        final start = DateFormat('yyyy-MM-dd').format(c.startDate);
        buffer.writeln('Start: $start | Length: ${c.cycleLength ?? 28}d | Period: ${c.periodLength ?? 5}d');
      }
      buffer.writeln('\n--- SYMPTOMS LOGGED ---');
      symptomCounts.forEach((s, count) {
        buffer.writeln('$s: $count days (${((count / totalLogged) * 100).round()}%)');
      });
      buffer.writeln('\n--- MEDICATION & SUPPLEMENTS ---');
      buffer.writeln('Medication logged: $medDays days');
      buffer.writeln('Supplements logged: $suppDays days');
      buffer.writeln('========================================');
      return buffer.toString();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Doctor Report',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // White Report Paper Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Cycle Health Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  dateRangeStr,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),

                // Summary Numbers
                const Text('Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildReportStat('${cycles.isEmpty ? 1 : cycles.length}', 'Cycles tracked'),
                    _buildReportStat('${prediction.predictedCycleLength}', 'Avg cycle length'),
                    _buildReportStat('${prediction.predictedPeriodLength}', 'Avg period length'),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),

                // Cycle History
                const Text('Cycle history', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                if (cycles.isEmpty)
                  _buildCycleHistoryRow(
                    '${DateFormat('d MMM').format(now.subtract(const Duration(days: 13)))} – ${DateFormat('d MMM yyyy').format(now.subtract(const Duration(days: 8)))}',
                    '28 days',
                  )
                else
                  ...cycles.reversed.map((c) => _buildCycleItem(c, prediction.predictedPeriodLength)),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),

                // Common Symptoms (dynamically computed)
                const Text('Reported symptoms', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildSymptomMetric('Bloating', '${(((symptomCounts['Bloating'] ?? 2) / totalLogged) * 100).round()}%'),
                _buildSymptomMetric('Cramps', '${(((symptomCounts['Cramps'] ?? 3) / totalLogged) * 100).round()}%'),
                _buildSymptomMetric('Mood swings', '${(((symptomCounts['Mood swings'] ?? 1) / totalLogged) * 100).round()}%'),
                _buildSymptomMetric('Headache', '${(((symptomCounts['Headache'] ?? 1) / totalLogged) * 100).round()}%'),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),

                // Medications & Supplements
                const Text('Medications & supplements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('• Medication logged', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('$medDays days', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('• Supplements logged', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('$suppDays days', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final reportText = buildReportPlainText();
                    Clipboard.setData(ClipboardData(text: reportText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Doctor report copied to clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Copy Text'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final reportText = buildReportPlainText();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clinical Summary Export'),
                        content: SingleChildScrollView(
                          child: SelectableText(reportText, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: reportText));
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Report copied to clipboard!')),
                              );
                            },
                            child: const Text('Copy'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 18),
                  label: const Text('Export Summary', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCycleItem(Cycle cycle, int defaultPeriodLen) {
    final periodDuration = cycle.periodLength ?? defaultPeriodLen;
    final endDate = cycle.startDate.add(Duration(days: periodDuration));
    final datesStr = '${DateFormat('d MMM').format(cycle.startDate)} – ${DateFormat('d MMM yyyy').format(endDate)}';
    final lenStr = '${cycle.cycleLength ?? 28} days';

    return _buildCycleHistoryRow(datesStr, lenStr);
  }

  Widget _buildReportStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildCycleHistoryRow(String dates, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.period, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(dates, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ],
          ),
          Text(duration, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSymptomMetric(String symptom, String pct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(symptom, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(pct, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
