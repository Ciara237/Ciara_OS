import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/enums/domain.dart';
import 'package:drift/drift.dart';

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.domain,
    required this.wordCount,
    required this.createdAt,
    required this.updatedAt,
    this.notionPageId,
    this.notionUrl,
    this.notionLastEdited,
    this.isNotionSynced = false,
  });

  final int id;
  final String title;
  final String content;
  final Domain domain;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notionPageId;
  final String? notionUrl;
  final DateTime? notionLastEdited;
  final bool isNotionSynced;

  factory Note.fromRow(db.Note row) {
    return Note(
      id: row.id,
      title: row.title,
      content: row.content,
      domain: Domain.values.byName(row.domain),
      wordCount: row.wordCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      notionPageId: row.notionPageId,
      notionUrl: row.notionUrl,
      notionLastEdited: row.notionLastEdited,
      isNotionSynced: row.isNotionSynced,
    );
  }

  db.NotesCompanion toCompanion({bool forInsert = false}) {
    return db.NotesCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      title: Value(title),
      content: Value(content),
      domain: Value(domain.name),
      wordCount: Value(wordCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      notionPageId: Value(notionPageId),
      notionUrl: Value(notionUrl),
      notionLastEdited: Value(notionLastEdited),
      isNotionSynced: Value(isNotionSynced),
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    Domain? domain,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notionPageId,
    String? notionUrl,
    DateTime? notionLastEdited,
    bool? isNotionSynced,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      domain: domain ?? this.domain,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notionPageId: notionPageId ?? this.notionPageId,
      notionUrl: notionUrl ?? this.notionUrl,
      notionLastEdited: notionLastEdited ?? this.notionLastEdited,
      isNotionSynced: isNotionSynced ?? this.isNotionSynced,
    );
  }
}

int countWords(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return 0;
  }
  return trimmed.split(RegExp(r'\s+')).length;
}

String notePreview(String content, {int maxLines = 2}) {
  final normalized = content.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty) {
    return 'No content yet.';
  }
  return normalized;
}
