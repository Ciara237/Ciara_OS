import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/router/app_router.dart';
import 'package:ciaraos/services/onboarding_notifier.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final onboardingNotifier = OnboardingNotifier();
  await onboardingNotifier.load();

  runApp(
    ProviderScope(
      overrides: [
        onboardingNotifierProvider.overrideWithValue(onboardingNotifier),
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

    return MaterialApp.router(
      title: 'Ciara OS',
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
