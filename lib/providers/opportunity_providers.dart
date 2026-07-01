import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/opportunity_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository(ref.watch(databaseProvider));
});

final allOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchAll();
});

final groupedOpportunitiesProvider =
    Provider<AsyncValue<Map<OpportunityStatus, List<Opportunity>>>>((ref) {
  final opps = ref.watch(allOpportunitiesProvider);
  return opps.whenData((list) {
    final map = <OpportunityStatus, List<Opportunity>>{};
    for (final status in OpportunityStatus.values) {
      final group = list.where((o) => o.status == status).toList();
      if (group.isNotEmpty) {
        map[status] = group;
      }
    }
    return map;
  });
});

final activeOpportunitiesCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(allOpportunitiesProvider).whenData(
        (list) => list
            .where(
              (o) =>
                  o.status != OpportunityStatus.rejected &&
                  o.status != OpportunityStatus.closed,
            )
            .length,
      );
});
