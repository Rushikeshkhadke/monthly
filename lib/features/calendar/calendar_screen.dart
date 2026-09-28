import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers/cycle_providers.dart';
import '../logging/widgets/log_day_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final prediction = ref.watch(predictionProvider);
    final dayStatus = ref.watch(todayStatusProvider);

    final monthTitle = DateFormat('MMMM yyyy').format(_focusedMonth);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Month Navigator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                          });
                        },
                      ),
                      Text(
                        monthTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Calendar Grid Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider, width: 0.8),
                    ),
                    child: Column(
                      children: [
                        // Weekday labels
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _WeekdayHeader('Mon'),
                            _WeekdayHeader('Tue'),
                            _WeekdayHeader('Wed'),
                            _WeekdayHeader('Thu'),
                            _WeekdayHeader('Fri'),
                            _WeekdayHeader('Sat'),
                            _WeekdayHeader('Sun'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Days grid
                        _buildDaysGrid(prediction),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Legend
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      _buildLegendItem(AppColors.period, 'Period'),
                      _buildLegendItem(AppColors.fertile, 'Fertile window'),
                      _buildLegendItem(AppColors.ovulation, 'Ovulation'),
                      _buildLegendItem(AppColors.predicted, 'Predicted period', isBorderOnly: true),
                      _buildLegendItem(AppColors.textTertiary, 'Other days'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Log Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => LogDaySheet.show(context, _selectedDate),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Cycle View Progress Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cycle view',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: dayStatus.cycleDay / dayStatus.totalCycleDays,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.fertile),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day ${dayStatus.cycleDay} of ${dayStatus.totalCycleDays}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${dayStatus.daysUntilNextPeriod} days left',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysGrid(dynamic prediction) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1 = Mon, 7 = Sun

    final List<Widget> dayWidgets = [];

    // Empty lead cells
    for (int i = 1; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 36));
    }

    // Days in current month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;

      // Determine day color style based on day of month for mock demo
      Color? circleColor;
      Color textColor = AppColors.textPrimary;
      bool isBorder = false;

      if (day >= 6 && day <= 9) {
        circleColor = AppColors.period;
        textColor = Colors.white;
      } else if (day >= 15 && day <= 20) {
        circleColor = AppColors.fertile;
        textColor = Colors.white;
      } else if (day == 18) {
        circleColor = AppColors.ovulation;
        textColor = Colors.white;
      } else if (day >= 26 && day <= 28) {
        isBorder = true;
        circleColor = AppColors.predicted;
      }

      dayWidgets.add(
        InkWell(
          onTap: () => setState(() => _selectedDate = date),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBorder ? Colors.transparent : circleColor,
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : (isBorder ? Border.all(color: circleColor ?? AppColors.predicted, width: 1.5) : null),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: circleColor != null || isSelected ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: dayWidgets,
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isBorderOnly = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isBorderOnly ? Colors.transparent : color,
            border: isBorderOnly ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String label;
  const _WeekdayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
