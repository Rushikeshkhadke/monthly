import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/daily_log.dart';

class LogDaySheet extends StatefulWidget {
  final DateTime date;
  final VoidCallback? onSaved;

  const LogDaySheet({
    super.key,
    required this.date,
    this.onSaved,
  });

  static Future<void> show(BuildContext context, DateTime date, {VoidCallback? onSaved}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogDaySheet(date: date, onSaved: onSaved),
    );
  }

  @override
  State<LogDaySheet> createState() => _LogDaySheetState();
}

class _LogDaySheetState extends State<LogDaySheet> {
  FlowIntensity _flow = FlowIntensity.none;
  MoodType? _mood = MoodType.calm;
  int _painLevel = 0;
  int _energyLevel = 3;
  final Set<String> _selectedSymptoms = <String>{};
  bool _medication = false;
  bool _supplements = false;
  bool _workout = false;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = true;
  bool _hasExistingLog = false;

  final List<String> _allSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Acne',
    'Back pain',
    'Fatigue',
    'Nausea',
    'Breast tenderness',
    'Mood swings',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingLog();
  }

  Future<void> _loadExistingLog() async {
    final log = await AppDatabase.instance.getDailyLog(widget.date);
    if (log != null && mounted) {
      setState(() {
        _hasExistingLog = true;
        _flow = log.flow;
        _mood = log.mood ?? MoodType.calm;
        _painLevel = log.painLevel;
        _energyLevel = log.energyLevel;
        _selectedSymptoms.clear();
        _selectedSymptoms.addAll(log.symptoms);
        _medication = log.medication;
        _supplements = log.supplements;
        _workout = log.workout;
        _notesController.text = log.notes ?? '';
      });
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dailyLog = DailyLog(
      logDate: widget.date,
      flow: _flow,
      mood: _mood,
      painLevel: _painLevel,
      energyLevel: _energyLevel,
      symptoms: _selectedSymptoms.toList(),
      medication: _medication,
      supplements: _supplements,
      workout: _workout,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    await AppDatabase.instance.saveDailyLog(dailyLog);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log saved on device!'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _deleteLog() async {
    await AppDatabase.instance.deleteDailyLog(widget.date);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Day log removed.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(widget.date);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Top pill handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Sheet Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log for $formattedDate',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Scrollable log options
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
                    children: [
                      // 1. Flow
                      const Text('Flow', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Row(
                        children: FlowIntensity.values.map((f) {
                          final isSelected = _flow == f;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () => setState(() => _flow = f),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.periodLight : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppColors.period : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.water_drop,
                                        color: isSelected ? AppColors.period : AppColors.textSecondary,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        f.name[0].toUpperCase() + f.name.substring(1),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? AppColors.period : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // 2. Mood
                      const Text('Mood', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMoodOption('😊', 'Happy', MoodType.happy),
                          _buildMoodOption('😌', 'Calm', MoodType.calm),
                          _buildMoodOption('😤', 'Irritable', MoodType.irritable),
                          _buildMoodOption('😢', 'Sad', MoodType.sad),
                          _buildMoodOption('😰', 'Anxious', MoodType.anxious),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Pain Level (0 to 5)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pain Level', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('$_painLevel / 5', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      Slider(
                        value: _painLevel.toDouble(),
                        min: 0,
                        max: 5,
                        divisions: 5,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.surfaceVariant,
                        onChanged: (v) => setState(() => _painLevel = v.toInt()),
                      ),
                      const SizedBox(height: 16),

                      // Energy Level (1 to 5)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Energy Level', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('$_energyLevel / 5', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.fertile)),
                        ],
                      ),
                      Slider(
                        value: _energyLevel.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        activeColor: AppColors.fertile,
                        inactiveColor: AppColors.surfaceVariant,
                        onChanged: (v) => setState(() => _energyLevel = v.toInt()),
                      ),
                      const SizedBox(height: 16),

                      // 3. Symptoms
                      const Text('Symptoms', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allSymptoms.map((symptom) {
                          final isSelected = _selectedSymptoms.contains(symptom);
                          return FilterChip(
                            label: Text(symptom),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSymptoms.add(symptom);
                                } else {
                                  _selectedSymptoms.remove(symptom);
                                }
                              });
                            },
                            selectedColor: AppColors.primaryLight,
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            backgroundColor: AppColors.surfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // 4. Other Trackers
                      const Text('Other trackers', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      _buildTrackerSwitch(Icons.medication_outlined, 'Medication', _medication, (v) => setState(() => _medication = v)),
                      _buildTrackerSwitch(Icons.eco_outlined, 'Supplements', _supplements, (v) => setState(() => _supplements = v)),
                      _buildTrackerSwitch(Icons.fitness_center_outlined, 'Workout', _workout, (v) => setState(() => _workout = v)),
                      const SizedBox(height: 24),

                      // 5. Notes
                      const Text('Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add a note (optional)...',
                          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Save Button
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      if (_hasExistingLog) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _deleteLog,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Delete / Clear this log', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOption(String emoji, String label, MoodType type) {
    final isSelected = _mood == type;
    return InkWell(
      onTap: () => setState(() => _mood = type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerSwitch(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
