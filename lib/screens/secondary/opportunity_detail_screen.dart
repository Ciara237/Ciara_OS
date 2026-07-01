import 'package:flutter/material.dart';

class OpportunityDetailScreen extends StatelessWidget {
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opportunity Detail')),
      body: Center(
        child: Text('Opportunity $opportunityId — coming soon.'),
      ),
    );
  }
}
