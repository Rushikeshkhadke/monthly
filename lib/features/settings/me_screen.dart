import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../doctor_report/doctor_report_screen.dart';
import '../privacy/privacy_security_screen.dart';
import 'reminders_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Custom trackers',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'Doctor report',
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
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & security',
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
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Monthly',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '100% On-Device & Privacy First.\nNo servers, no tracking.',
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
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
