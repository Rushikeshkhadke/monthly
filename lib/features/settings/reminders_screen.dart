import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _periodReminders = true;
  bool _ironMed = true;
  bool _vitaminD = true;
  bool _painRelief = false;
  bool _trackSymptoms = true;
  bool _drinkWater = false;

  @override
  Widget build(BuildContext context) {
    // Rendered with Dark Mode styling as shown in Screen 10 of design reference
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.darkBackground,
      ),
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Reminders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, color: AppColors.primaryLight, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Period reminders',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      Switch(
                        value: _periodReminders,
                        activeColor: AppColors.primaryLight,
                        onChanged: (v) => setState(() => _periodReminders = v),
                      ),
                    ],
                  ),
                  if (_periodReminders) ...[
                    const Divider(height: 20, color: AppColors.darkSurfaceVariant),
                    _buildDarkDetailRow('Period due reminder', '3 days before >'),
                    const SizedBox(height: 12),
                    _buildDarkDetailRow('Period start reminder', 'On day 1 >'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Medication Reminders Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMedicationRow(
                    icon: '💊',
                    title: 'Iron supplement',
                    subtitle: 'Daily • 8:00 AM',
                    value: _ironMed,
                    onChanged: (v) => setState(() => _ironMed = v),
                  ),
                  const Divider(height: 20, color: AppColors.darkSurfaceVariant),
                  _buildMedicationRow(
                    icon: '🌿',
                    title: 'Vitamin D',
                    subtitle: 'Daily • 8:00 AM',
                    value: _vitaminD,
                    onChanged: (v) => setState(() => _vitaminD = v),
                  ),
                  const Divider(height: 20, color: AppColors.darkSurfaceVariant),
                  _buildMedicationRow(
                    icon: '⚡',
                    title: 'Pain relief (if needed)',
                    subtitle: 'As needed',
                    value: _painRelief,
                    onChanged: (v) => setState(() => _painRelief = v),
                  ),
                  const SizedBox(height: 18),
                  // Add reminder button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
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
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Other reminders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  _buildMedicationRow(
                    icon: '🔔',
                    title: 'Track my symptoms',
                    subtitle: 'Daily • 9:00 PM',
                    value: _trackSymptoms,
                    onChanged: (v) => setState(() => _trackSymptoms = v),
                  ),
                  const Divider(height: 20, color: AppColors.darkSurfaceVariant),
                  _buildMedicationRow(
                    icon: '💧',
                    title: 'Drink water',
                    subtitle: 'Daily • 12:00 PM',
                    value: _drinkWater,
                    onChanged: (v) => setState(() => _drinkWater = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkDetailRow(String title, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: AppColors.darkTextSecondary)),
        Text(trailing, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _buildMedicationRow({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
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
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.primaryLight,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
