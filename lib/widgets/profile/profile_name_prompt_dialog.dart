import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> showProfileNamePromptDialog(
  BuildContext context,
  WidgetRef ref, {
  bool isFirstTime = true,
}) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: !isFirstTime,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        title: Text(
          isFirstTime ? 'Welcome to Ciara OS' : 'Edit display name',
          style: AppTypography.headingMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isFirstTime
                    ? 'Enter your name to personalize your profile and avatar.'
                    : 'Update the name shown across Ciara OS.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  hintText: 'e.g. Ciara M.',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.pop(dialogContext, true);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          if (!isFirstTime)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(isFirstTime ? 'Continue' : 'Save'),
          ),
        ],
      );
    },
  );

  if (saved == true && context.mounted) {
    await ref.read(profileProvider.notifier).saveDisplayName(controller.text);
  }

  controller.dispose();
}

/// Prompts first-time users to set a display name once onboarding is complete.
class ProfileNameSetupGate extends ConsumerStatefulWidget {
  const ProfileNameSetupGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ProfileNameSetupGate> createState() =>
      _ProfileNameSetupGateState();
}

class _ProfileNameSetupGateState extends ConsumerState<ProfileNameSetupGate> {
  bool _promptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  Future<void> _maybePrompt() async {
    if (_promptShown || !mounted) {
      return;
    }

    final location = GoRouterState.of(context).uri.path;
    if (location == '/daily-brief') {
      return;
    }

    final onboarding = ref.read(onboardingNotifierProvider);
    if (!onboarding.isComplete) {
      return;
    }

    final profile = ref.read(profileProvider);
    if (profile.isNameConfigured) {
      return;
    }

    _promptShown = true;
    await showProfileNamePromptDialog(context, ref, isFirstTime: true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
