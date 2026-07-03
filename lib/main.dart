import 'package:ciaraos/providers/daily_brief_gate_provider.dart';
import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/providers/theme_provider.dart';
import 'package:ciaraos/router/app_router.dart';
import 'package:ciaraos/services/daily_brief_prefs.dart';
import 'package:ciaraos/services/onboarding_notifier.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/widgets/profile/profile_name_prompt_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final onboardingNotifier = OnboardingNotifier();
  await onboardingNotifier.load();

  final dailyBriefGate = DailyBriefGateNotifier();
  await dailyBriefGate.load(prefs);
  final themeMode = await loadPersistedThemeMode();

  runApp(
    ProviderScope(
      overrides: [
        onboardingNotifierProvider.overrideWithValue(onboardingNotifier),
        dailyBriefGateProvider.overrideWithValue(dailyBriefGate),
        themeModeProvider.overrideWith((ref) => themeMode),
      ],
      child: const CiaraOsApp(),
    ),
  );
}

/// Root app shell — router and screens expand in later milestones.
class CiaraOsApp extends ConsumerWidget {
  const CiaraOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Ciara OS',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        return ProfileNameSetupGate(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
