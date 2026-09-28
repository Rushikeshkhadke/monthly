import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/main_scaffold.dart';
import 'app/theme/app_theme.dart';
import 'core/providers/cycle_providers.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MonthlyApp(),
    ),
  );
}

class MonthlyApp extends ConsumerWidget {
  const MonthlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Monthly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode == 'dark'
          ? ThemeMode.dark
          : settings.themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.system,
      home: settings.onboardingCompleted
          ? const MainScaffold()
          : const OnboardingScreen(),
    );
  }
}
