import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers/cycle_providers.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _ironMed = true;
  bool _vitaminD = true;
  bool _painRelief = false;
  bool _trackSymptoms = true;
  bool _drinkWater = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBorder = isDark ? BorderSide.none : const BorderSide(color: AppColors.divider, width: 0.8);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.darkSurfaceVariant : AppColors.divider;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reminders',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Period Reminders Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: cardBorder != BorderSide.none ? Border.fromBorderSide(cardBorder) : null,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Period reminders',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.notificationsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (v) {
                        ref.read(settingsProvider.notifier).update(settings.copyWith(notificationsEnabled: v));
                      },
                    ),
                  ],
                ),
                if (settings.notificationsEnabled) ...[
                  Divider(height: 20, color: dividerColor),
                  _buildDetailRow('Period due reminder', '${settings.periodReminderDaysBefore} days before >', textColor, subtextColor),
                  const SizedBox(height: 12),
                  _buildDetailRow('Period start reminder', 'On day 1 >', textColor, subtextColor),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Medication Reminders Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: cardBorder != BorderSide.none ? Border.fromBorderSide(cardBorder) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMedicationRow(
                  icon: '💊',
                  title: 'Iron supplement',
                  subtitle: 'Daily • 8:00 AM',
                  value: _ironMed,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onChanged: (v) => setState(() => _ironMed = v),
                ),
                Divider(height: 20, color: dividerColor),
                _buildMedicationRow(
                  icon: '🌿',
                  title: 'Vitamin D',
                  subtitle: 'Daily • 8:00 AM',
                  value: _vitaminD,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onChanged: (v) => setState(() => _vitaminD = v),
                ),
                Divider(height: 20, color: dividerColor),
                _buildMedicationRow(
                  icon: '⚡',
                  title: 'Pain relief (if needed)',
                  subtitle: 'As needed',
                  value: _painRelief,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onChanged: (v) => setState(() => _painRelief = v),
                ),
                const SizedBox(height: 18),
                // Add reminder button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Custom reminder saved!')),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('+ Add reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Other Reminders Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: cardBorder != BorderSide.none ? Border.fromBorderSide(cardBorder) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Other reminders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                _buildMedicationRow(
                  icon: '🔔',
                  title: 'Track my symptoms',
                  subtitle: 'Daily • 9:00 PM',
                  value: _trackSymptoms,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onChanged: (v) => setState(() => _trackSymptoms = v),
                ),
                Divider(height: 20, color: dividerColor),
                _buildMedicationRow(
                  icon: '💧',
                  title: 'Drink water',
                  subtitle: 'Daily • 12:00 PM',
                  value: _drinkWater,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  onChanged: (v) => setState(() => _drinkWater = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String trailing, Color textColor, Color subtextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: subtextColor)),
        Text(trailing, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
      ],
    );
  }

  Widget _buildMedicationRow({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color textColor,
    required Color subtextColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: subtextColor)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
