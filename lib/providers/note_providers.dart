import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/note.dart';
import 'package:ciaraos/models/notion_page.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/note_repository.dart';
import 'package:ciaraos/services/notion_api_client.dart';
import 'package:ciaraos/services/notion_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(ref.watch(databaseProvider));
});

final notionSyncServiceProvider = Provider<NotionSyncService>((ref) {
  return NotionSyncService(
    ref.read(noteRepositoryProvider),
    NotionApiClient(),
  );
});

final notionHealthProvider = FutureProvider<NotionHealthStatus>((ref) {
  return NotionApiClient().checkHealth();
});

final notionLastSyncedAtProvider = FutureProvider<DateTime?>((ref) {
  return loadNotionLastSyncedAt();
});

final notionSyncedNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  return ref.watch(allNotesProvider).whenData(
        (notes) => notes.where((note) => note.isNotionSynced).toList(),
      );
});

final allNotesProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchAll();
});

final noteSearchQueryProvider = StateProvider<String>((ref) => '');

final noteDomainFilterProvider = StateProvider<Domain?>((ref) => null);

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(allNotesProvider);
  final query = ref.watch(noteSearchQueryProvider).trim().toLowerCase();
  final domain = ref.watch(noteDomainFilterProvider);

  return notesAsync.whenData((notes) {
    var filtered = notes;
    if (domain != null) {
      filtered = filtered.where((note) => note.domain == domain).toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (note) =>
                note.title.toLowerCase().contains(query) ||
                note.content.toLowerCase().contains(query),
          )
          .toList();
    }
    return filtered;
  });
});

final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) {
  return ref.read(noteRepositoryProvider).getById(id);
});
