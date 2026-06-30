import 'package:ciaraos/providers/navigation_provider.dart';
import 'package:ciaraos/widgets/navigation/primary_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrimaryShellScaffold extends ConsumerWidget {
  const PrimaryShellScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  static int tabIndexForLocation(String location) {
    if (location.startsWith('/tasks') && location != '/tasks') {
      return 1;
    }
    for (var i = 0; i < kPrimaryNavDestinations.length; i++) {
      final route = kPrimaryNavDestinations[i].route;
      if (route == '/' && location == '/') {
        return 0;
      }
      if (route != '/' && location.startsWith(route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final tabIndex = tabIndexForLocation(location);

    if (ref.read(selectedTabProvider) != tabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedTabProvider.notifier).state = tabIndex;
      });
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: const PrimaryNavBar(),
    );
  }
}
