import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Add/Edit Opportunity — stub until Pipeline detail milestone.
class OpportunityCreateEditScreen extends StatelessWidget {
  const OpportunityCreateEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Opportunity'),
        actions: [
          TextButton(
            onPressed: () => context.go('/opportunities'),
            child: const Text('Save'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Opportunity form — coming soon.'),
      ),
    );
  }
}
