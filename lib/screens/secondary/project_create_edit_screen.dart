import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Add/Edit Project — stub until Projects detail milestone.
class ProjectCreateEditScreen extends StatelessWidget {
  const ProjectCreateEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        actions: [
          TextButton(
            onPressed: () => context.go('/projects'),
            child: const Text('Save'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Project form — coming soon.'),
      ),
    );
  }
}
