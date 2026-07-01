import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Add/Edit Opportunity — stub until full form milestone.
class OpportunityCreateEditScreen extends StatelessWidget {
  const OpportunityCreateEditScreen({super.key, this.opportunityId});

  final String? opportunityId;

  @override
  Widget build(BuildContext context) {
    final isEdit = opportunityId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Opportunity' : 'New Opportunity'),
        actions: [
          TextButton(
            onPressed: () {
              if (isEdit) {
                context.go('/opportunities/$opportunityId');
              } else {
                context.go('/opportunities');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Center(
        child: Text(
          isEdit
              ? 'Edit opportunity $opportunityId — coming soon.'
              : 'Opportunity form — coming soon.',
        ),
      ),
    );
  }
}
