import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/enums/domain.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

enum ResourceType {
  course,
  documentation,
  tool,
  article,
  book,
  drive,
}

class Resource {
  const Resource({
    required this.id,
    required this.title,
    required this.url,
    required this.domain,
    required this.type,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String url;
  final Domain domain;
  final ResourceType type;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Resource.fromRow(db.Resource row) {
    return Resource(
      id: row.id,
      title: row.title,
      url: row.url,
      domain: Domain.values.byName(row.domain),
      type: ResourceType.values.byName(row.type),
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  db.ResourcesCompanion toCompanion({bool forInsert = false}) {
    return db.ResourcesCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      title: Value(title),
      url: Value(url),
      domain: Value(domain.name),
      type: Value(type.name),
      description: Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  Resource copyWith({
    int? id,
    String? title,
    String? url,
    Domain? domain,
    ResourceType? type,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      domain: domain ?? this.domain,
      type: type ?? this.type,
      description: clearDescription ? null : (description ?? this.description),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String resourceTypeLabel(ResourceType type) {
  return switch (type) {
    ResourceType.course => 'COURSE',
    ResourceType.documentation => 'DOCS',
    ResourceType.tool => 'TOOL',
    ResourceType.article => 'ARTICLE',
    ResourceType.book => 'BOOK',
    ResourceType.drive => 'DRIVE',
  };
}

IconData resourceTypeIcon(ResourceType type) {
  return switch (type) {
    ResourceType.course => Icons.school_outlined,
    ResourceType.documentation => Icons.menu_book_outlined,
    ResourceType.tool => Icons.build_outlined,
    ResourceType.article => Icons.article_outlined,
    ResourceType.book => Icons.auto_stories_outlined,
    ResourceType.drive => Icons.folder_outlined,
  };
}

/// Google Drive green — kept here rather than [AppColors].
const driveResourceColor = Color(0xFF1FA463);

Color resourceTypeColor(ResourceType type, ColorScheme colorScheme) {
  return switch (type) {
    ResourceType.drive => driveResourceColor,
    _ => colorScheme.primary,
  };
}
