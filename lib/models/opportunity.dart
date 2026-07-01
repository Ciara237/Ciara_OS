import 'dart:convert';

import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/enums/opportunity_type.dart';
import 'package:drift/drift.dart';

class OpportunityDocument {
  const OpportunityDocument({
    required this.name,
    required this.required,
    required this.completed,
  });

  final String name;
  final bool required;
  final bool completed;

  factory OpportunityDocument.fromJson(Map<String, dynamic> json) {
    return OpportunityDocument(
      name: json['name'] as String,
      required: json['required'] as bool,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'required': required,
        'completed': completed,
      };
}

class Opportunity {
  const Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.type,
    required this.status,
    this.deadline,
    this.fitNotes,
    this.documents = const [],
    required this.documentsTotal,
    required this.documentsReady,
    this.link,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String organization;
  final OpportunityType type;
  final OpportunityStatus status;
  final DateTime? deadline;
  final String? fitNotes;
  final List<OpportunityDocument> documents;
  final int documentsTotal;
  final int documentsReady;
  final String? link;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Opportunity.fromRow(db.Opportunity row) {
    return Opportunity(
      id: row.id,
      title: row.title,
      organization: row.organization,
      type: OpportunityType.values.byName(row.type),
      status: OpportunityStatus.values.byName(row.status),
      deadline: row.deadline,
      fitNotes: row.fitNotes,
      documents: _documentsFromJson(row.documents),
      documentsTotal: row.documentsTotal,
      documentsReady: row.documentsReady,
      link: row.link,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static List<OpportunityDocument> _documentsFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map(
          (entry) => OpportunityDocument.fromJson(
            entry as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static String? _documentsToJson(List<OpportunityDocument> documents) {
    if (documents.isEmpty) {
      return null;
    }

    return jsonEncode(documents.map((doc) => doc.toJson()).toList());
  }

  db.OpportunitiesCompanion toCompanion({bool forInsert = false}) {
    return db.OpportunitiesCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      title: Value(title),
      organization: Value(organization),
      type: Value(type.name),
      status: Value(status.name),
      deadline: Value(deadline),
      fitNotes: Value(fitNotes),
      documents: Value(_documentsToJson(documents)),
      documentsTotal: Value(documentsTotal),
      documentsReady: Value(documentsReady),
      link: Value(link),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  Opportunity copyWith({
    int? id,
    String? title,
    String? organization,
    OpportunityType? type,
    OpportunityStatus? status,
    DateTime? deadline,
    String? fitNotes,
    List<OpportunityDocument>? documents,
    int? documentsTotal,
    int? documentsReady,
    String? link,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDeadline = false,
    bool clearFitNotes = false,
    bool clearLink = false,
  }) {
    return Opportunity(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      type: type ?? this.type,
      status: status ?? this.status,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      fitNotes: clearFitNotes ? null : (fitNotes ?? this.fitNotes),
      documents: documents ?? this.documents,
      documentsTotal: documentsTotal ?? this.documentsTotal,
      documentsReady: documentsReady ?? this.documentsReady,
      link: clearLink ? null : (link ?? this.link),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
