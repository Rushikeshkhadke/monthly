import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthly/core/models/user_settings.dart';
import 'package:monthly/core/providers/cycle_providers.dart';
import 'package:monthly/main.dart';

class FakeSettingsNotifier extends StateNotifier<UserSettings> implements SettingsNotifier {
  FakeSettingsNotifier() : super(const UserSettings(onboardingCompleted: false));

  @override
  Future<void> completeOnboarding({
    required int cycleLength,
    required int periodLength,
    required DateTime lastPeriodDate,
  }) async {
    state = state.copyWith(onboardingCompleted: true);
  }

  @override
  Future<void> update(UserSettings newSettings) async {
    state = newSettings;
  }
}

void main() {
  testWidgets('MonthlyApp smoke test renders onboarding or main scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith((ref) => FakeSettingsNotifier()),
        ],
        child: const MonthlyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify wordmark and onboarding elements render correctly
    expect(find.text('Monthly'), findsWidgets);
    expect(find.text('Get started'), findsOneWidget);
  });
}
