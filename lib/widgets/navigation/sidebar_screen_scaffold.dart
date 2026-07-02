import 'package:ciaraos/widgets/navigation/primary_drawer.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';

/// Scaffold for routes opened from the sidebar — includes drawer + [TodayHeader].
class SidebarScreenScaffold extends StatelessWidget {
  const SidebarScreenScaffold({
    super.key,
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const PrimaryDrawer(),
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TodayHeader(),
          Expanded(child: body),
        ],
      ),
    );
  }
}
