import 'package:ciaraos/providers/daily_brief_gate_provider.dart';
import 'package:ciaraos/providers/notification_providers.dart';
import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/providers/theme_provider.dart';
import 'package:ciaraos/router/app_router.dart';
import 'package:ciaraos/services/daily_brief_prefs.dart';
import 'package:ciaraos/services/onboarding_notifier.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/widgets/daily_brief/daily_brief_gate_overlay.dart';
import 'package:ciaraos/widgets/profile/profile_name_prompt_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

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
class CiaraOsApp extends ConsumerStatefulWidget {
  const CiaraOsApp({super.key});

  @override
  ConsumerState<CiaraOsApp> createState() => _CiaraOsAppState();
}

class _CiaraOsAppState extends ConsumerState<CiaraOsApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeNotificationService(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
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
        return DailyBriefGateOverlay(
          child: ProfileNameSetupGate(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}