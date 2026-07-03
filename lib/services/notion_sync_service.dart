import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/note.dart';
import 'package:ciaraos/models/notion_page.dart';
import 'package:ciaraos/repositories/note_repository.dart';
import 'package:ciaraos/services/notion_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const notionLastSyncedPreferenceKey = 'notion_last_synced_at';

Future<DateTime?> loadNotionLastSyncedAt() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(notionLastSyncedPreferenceKey);
  if (raw == null) {
    return null;
  }
  return DateTime.tryParse(raw);
}

Future<void> saveNotionLastSyncedAt(DateTime syncedAt) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    notionLastSyncedPreferenceKey,
    syncedAt.toUtc().toIso8601String(),
  );
}

enum _UpsertOutcome { added, updated, unchanged }

class NotionSyncService {
  NotionSyncService(this._noteRepo, this._api);

  final NoteRepository _noteRepo;
  final NotionApiClient _api;

  Future<NotionSyncResult> syncAll({bool force = false}) async {
    final response = await _api.fetchPages(force: force);
    if (response == null) {
      throw StateError('Could not fetch Notion pages from backend.');
    }

    var added = 0;
    var updated = 0;
    var unchanged = 0;
    final syncedAt = DateTime.parse(response.syncedAt).toLocal();

    for (final page in response.pages) {
      final outcome = await _upsertPage(page);
      switch (outcome) {
        case _UpsertOutcome.added:
          added++;
        case _UpsertOutcome.updated:
          updated++;
        case _UpsertOutcome.unchanged:
          unchanged++;
      }
    }

    await saveNotionLastSyncedAt(syncedAt);
    return NotionSyncResult(
      added: added,
      updated: updated,
      unchanged: unchanged,
      syncedAt: syncedAt,
    );
  }

  Future<void> syncPage(String pageId) async {
    final page = await _api.fetchPage(pageId);
    if (page == null) {
      throw StateError('Could not sync Notion page $pageId.');
    }

    await _upsertPage(page);
    await saveNotionLastSyncedAt(DateTime.now());
  }

  Future<_UpsertOutcome> _upsertPage(NotionPage page) async {
    final editedAt = DateTime.parse(page.lastEdited).toUtc();
    final domain = _parseDomain(page.domain);
    final existing = await _noteRepo.getByNotionPageId(page.id);
    final now = DateTime.now();

    if (existing != null) {
      final previousEdited = existing.notionLastEdited?.toUtc();
      if (previousEdited != null &&
          previousEdited.isAtSameMomentAs(editedAt) &&
          existing.title == page.title &&
          existing.content == page.content &&
          existing.domain == domain &&
          existing.wordCount == page.wordCount) {
        return _UpsertOutcome.unchanged;
      }

      final updated = existing.copyWith(
        title: page.title,
        content: page.content,
        domain: domain,
        wordCount: page.wordCount,
        updatedAt: now,
        notionUrl: page.notionUrl,
        notionLastEdited: editedAt.toLocal(),
        isNotionSynced: true,
      );
      await _noteRepo.update(updated.toCompanion());
      return _UpsertOutcome.updated;
    }

    final note = Note(
      id: 0,
      title: page.title,
      content: page.content,
      domain: domain,
      wordCount: page.wordCount,
      createdAt: now,
      updatedAt: now,
      notionPageId: page.id,
      notionUrl: page.notionUrl,
      notionLastEdited: editedAt.toLocal(),
      isNotionSynced: true,
    );
    await _noteRepo.insert(note.toCompanion(forInsert: true));
    return _UpsertOutcome.added;
  }

  Domain _parseDomain(String? domain) {
    if (domain == null || domain.isEmpty) {
      return Domain.other;
    }
    try {
      return Domain.values.byName(domain);
    } catch (_) {
      return Domain.other;
    }
  }
}
