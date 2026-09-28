import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../core/models/cycle.dart';
import '../../core/math/cycle_predictor.dart';
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
    final cycles = ref.watch(cyclesProvider);

    // Compute status for the selected date dynamically
    final lastCycleStart = cycles.isNotEmpty
        ? cycles.last.startDate
        : DateTime.now().subtract(const Duration(days: 13));

    final selectedDayStatus = CyclePredictor.getDayStatus(
      targetDate: _selectedDate,
      currentCycleStartDate: lastCycleStart,
      prediction: prediction,
    );

    final monthTitle = DateFormat('MMMM yyyy').format(_focusedMonth);

    void refreshCalendar() {
      ref.invalidate(cyclesProvider);
      ref.invalidate(todayStatusProvider);
      ref.invalidate(predictionProvider);
      setState(() {});
    }

    final progressFraction = selectedDayStatus.totalCycleDays > 0
        ? (selectedDayStatus.cycleDay / selectedDayStatus.totalCycleDays).clamp(0.0, 1.0)
        : 0.0;

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
                        _buildDaysGrid(cycles, prediction),
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
                      _buildLegendItem(Colors.deepOrangeAccent, 'Overdue'),
                      _buildLegendItem(AppColors.textTertiary, 'Other days'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Log Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => LogDaySheet.show(
                        context,
                        _selectedDate,
                        onSaved: refreshCalendar,
                      ),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: Text(
                        'Log ${DateFormat('d MMM').format(_selectedDate)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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

            // Bottom Cycle View Progress Bar for Selected Date
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cycle view (${DateFormat('d MMM').format(_selectedDate)})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedDayStatus.phase.displayName,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        selectedDayStatus.phase == CyclePhase.late
                            ? Colors.deepOrangeAccent
                            : AppColors.fertile,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day ${selectedDayStatus.cycleDay} of ${selectedDayStatus.totalCycleDays}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      Text(
                        selectedDayStatus.daysUntilNextPeriod > 0
                            ? '${selectedDayStatus.daysUntilNextPeriod} days left'
                            : (selectedDayStatus.phase == CyclePhase.late ? 'Period overdue' : 'Period due'),
                        style: TextStyle(
                          fontSize: 12,
                          color: selectedDayStatus.phase == CyclePhase.late ? Colors.deepOrangeAccent : AppColors.textSecondary,
                          fontWeight: selectedDayStatus.phase == CyclePhase.late ? FontWeight.bold : FontWeight.normal,
                        ),
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

  Widget _buildDaysGrid(List<Cycle> cycles, PredictionResult prediction) {
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

      final phase = CyclePredictor.getCalendarDatePhase(
        date: date,
        cycles: cycles,
        prediction: prediction,
      );

      Color? circleColor;
      Color textColor = AppColors.textPrimary;
      bool isBorder = false;

      switch (phase) {
        case CyclePhase.menstrual:
          circleColor = AppColors.period;
          textColor = Colors.white;
          break;
        case CyclePhase.fertile:
          circleColor = AppColors.fertile;
          textColor = Colors.white;
          break;
        case CyclePhase.ovulation:
          circleColor = AppColors.ovulation;
          textColor = Colors.white;
          break;
        case CyclePhase.predictedPeriod:
          circleColor = AppColors.predicted;
          isBorder = true;
          break;
        case CyclePhase.late:
          circleColor = Colors.deepOrangeAccent;
          textColor = Colors.white;
          break;
        default:
          circleColor = null;
          textColor = AppColors.textPrimary;
          break;
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
