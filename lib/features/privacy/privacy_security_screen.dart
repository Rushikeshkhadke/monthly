import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _appLock = true;
  bool _useBiometric = true;
  bool _disguiseMode = false;
  bool _panicHide = true;
  int _selectedIconIndex = 0;

  final List<String> _disguiseIcons = ['🔢', '🌸', '🌿', '🌙'];

  @override
  Widget build(BuildContext context) {
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
          'Privacy & Security',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // App Lock Section Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider, width: 0.8),
            ),
            child: Column(
              children: [
                _buildToggleRow(
                  icon: Icons.lock_outline_rounded,
                  title: 'App lock',
                  subtitle: 'Use PIN or biometric to open the app',
                  value: _appLock,
                  onChanged: (v) => setState(() => _appLock = v),
                ),
                if (_appLock) ...[
                  const Divider(height: 20, indent: 44, color: AppColors.divider),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Change PIN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN setup verified.')),
                      );
                    },
                  ),
                  const Divider(height: 20, indent: 44, color: AppColors.divider),
                  _buildToggleRow(
                    icon: Icons.fingerprint_rounded,
                    title: 'Use biometric',
                    subtitle: 'Fingerprint or Face unlock',
                    value: _useBiometric,
                    onChanged: (v) => setState(() => _useBiometric = v),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Disguise Mode Section Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggleRow(
                  icon: Icons.visibility_off_outlined,
                  title: 'Disguise mode',
                  subtitle: 'App appears as a calculator to keep your data private.',
                  value: _disguiseMode,
                  onChanged: (v) => setState(() => _disguiseMode = v),
                ),
                if (_disguiseMode) ...[
                  const SizedBox(height: 16),
                  const Text('Choose app icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(_disguiseIcons.length, (index) {
                      final isSelected = _selectedIconIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => setState(() => _selectedIconIndex = index),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(_disguiseIcons[index], style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Panic Hide Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.divider, width: 0.8),
            ),
            child: _buildToggleRow(
              icon: Icons.remove_red_eye_outlined,
              title: 'Panic hide',
              subtitle: 'Quickly hide the app from recent apps',
              value: _panicHide,
              onChanged: (v) => setState(() => _panicHide = v),
            ),
          ),
          const SizedBox(height: 16),

          // Encrypted Backup Card
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Encrypted on-device backup created successfully!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 24),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Encrypted backup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        SizedBox(height: 2),
                        Text('Create an encrypted backup on your device.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 100% Local Device Guarantee Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fertileLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.fertile.withOpacity(0.3), width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.fertile,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All data stored on device', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Your data never leaves your phone.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
