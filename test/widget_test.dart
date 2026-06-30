import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/services/onboarding_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ciaraos/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Ciara OS shows onboarding on first launch', (tester) async {
    final onboardingNotifier = OnboardingNotifier();
    await onboardingNotifier.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingNotifierProvider.overrideWithValue(onboardingNotifier),
        ],
        child: const CiaraOsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Ciara OS'), findsOneWidget);
  });

  testWidgets('Ciara OS shows Today when onboarding complete', (tester) async {
    final onboardingNotifier = OnboardingNotifier();
    await onboardingNotifier.load();
    await onboardingNotifier.markComplete();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingNotifierProvider.overrideWithValue(onboardingNotifier),
          todayTasksProvider.overrideWith((ref) => Stream<List<Task>>.value([])),
          allProjectsProvider.overrideWith(
            (ref) => Stream<List<Project>>.value([]),
          ),
        ],
        child: const CiaraOsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EXECUTION VIEW'), findsOneWidget);
  });
}
