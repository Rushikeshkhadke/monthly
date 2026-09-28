import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../core/models/cycle.dart';
import '../../core/providers/cycle_providers.dart';

class DoctorReportScreen extends ConsumerWidget {
  const DoctorReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycles = ref.watch(cyclesProvider);
    final prediction = ref.watch(predictionProvider);

    final now = DateTime.now();
    final startDate = cycles.isNotEmpty
        ? cycles.first.startDate
        : now.subtract(const Duration(days: 90));
    final dateRangeStr =
        '${DateFormat('d MMM yyyy').format(startDate)} – ${DateFormat('d MMM yyyy').format(now)}';

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

                // Common Symptoms
                const Text('Common symptoms', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildSymptomMetric('Bloating', '68%'),
                _buildSymptomMetric('Cramps', '54%'),
                _buildSymptomMetric('Mood swings', '46%'),
                _buildSymptomMetric('Headache', '32%'),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),

                // Medications & Supplements
                const Text('Medications & supplements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('• Iron supplement', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('12 days', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('• Vitamin D', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('30 days', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preparing report to share...')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF generated and exported to device!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 18),
                  label: const Text('Export PDF', style: TextStyle(color: Colors.white)),
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
