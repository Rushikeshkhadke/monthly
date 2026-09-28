import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers/cycle_providers.dart';
import '../doctor_report/doctor_report_screen.dart';
import '../privacy/privacy_security_screen.dart';
import 'reminders_screen.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Header Profile Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Me',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Take control of your health',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: const Center(
                    child: Text('🌸', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Settings Group Card
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.divider, width: 0.8),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'My cycle settings',
                    subtitle: '${settings.defaultCycleLength} days cycle • ${settings.defaultPeriodLength} days period',
                    onTap: () => _openCycleSettingsSheet(context, ref, settings),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Custom trackers',
                    subtitle: 'Medication, Supplements, Workout',
                    onTap: () => _openTrackersSheet(context),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'Doctor report',
                    subtitle: 'Export cycle health summary',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DoctorReportScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.cloud_sync_outlined,
                    title: 'Backup & restore',
                    subtitle: 'Encrypted on-device backup',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & security',
                    subtitle: 'Biometric lock, disguise mode',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Reminders',
                    subtitle: 'Period and fertility alerts',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RemindersScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Appearance',
                    subtitle: settings.themeMode[0].toUpperCase() + settings.themeMode.substring(1),
                    onTap: () => _openAppearanceSheet(context, ref, settings),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'v1.0.0 • 100% Offline & Private',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Monthly',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '100% On-Device & Privacy First.\nNo servers, no tracking, zero telemetry.',
                      );
                    },
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  void _openCycleSettingsSheet(BuildContext context, WidgetRef ref, dynamic settings) {
    int cycleLen = settings.defaultCycleLength;
    int periodLen = settings.defaultPeriodLength;
    int lutealLen = settings.lutealPhaseLength;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'My Cycle Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),

              // Cycle length slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cycle Length', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('$cycleLen days', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              Slider(
                value: cycleLen.toDouble(),
                min: 21,
                max: 45,
                divisions: 24,
                activeColor: AppColors.primary,
                onChanged: (v) => setModalState(() => cycleLen = v.toInt()),
              ),
              const SizedBox(height: 12),

              // Period length slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Period Length', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('$periodLen days', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.period)),
                ],
              ),
              Slider(
                value: periodLen.toDouble(),
                min: 2,
                max: 10,
                divisions: 8,
                activeColor: AppColors.period,
                onChanged: (v) => setModalState(() => periodLen = v.toInt()),
              ),
              const SizedBox(height: 12),

              // Luteal phase slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Luteal Phase Length', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('$lutealLen days', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.fertile)),
                ],
              ),
              Slider(
                value: lutealLen.toDouble(),
                min: 10,
                max: 16,
                divisions: 6,
                activeColor: AppColors.fertile,
                onChanged: (v) => setModalState(() => lutealLen = v.toInt()),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final updated = settings.copyWith(
                      defaultCycleLength: cycleLen,
                      defaultPeriodLength: periodLen,
                      lutealPhaseLength: lutealLen,
                    );
                    await ref.read(settingsProvider.notifier).update(updated);
                    ref.invalidate(predictionProvider);
                    ref.invalidate(todayStatusProvider);
                    if (context.mounted) Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAppearanceSheet(BuildContext context, WidgetRef ref, dynamic settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System default'),
              trailing: settings.themeMode == 'system' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                ref.read(settingsProvider.notifier).update(settings.copyWith(themeMode: 'system'));
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light theme'),
              trailing: settings.themeMode == 'light' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                ref.read(settingsProvider.notifier).update(settings.copyWith(themeMode: 'light'));
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark theme'),
              trailing: settings.themeMode == 'dark' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                ref.read(settingsProvider.notifier).update(settings.copyWith(themeMode: 'dark'));
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openTrackersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Active Trackers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            const Text('These trackers appear on your Daily Log sheet:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.medication_outlined, color: AppColors.primary),
              title: Text('Medication'),
              subtitle: Text('Track daily prescriptions'),
            ),
            const ListTile(
              leading: Icon(Icons.eco_outlined, color: AppColors.fertile),
              title: Text('Supplements'),
              subtitle: Text('Vitamins and minerals'),
            ),
            const ListTile(
              leading: Icon(Icons.fitness_center_outlined, color: AppColors.ovulation),
              title: Text('Workout'),
              subtitle: Text('Exercise & physical activity'),
            ),
          ],
        ),
      ),
    );
  }
}
