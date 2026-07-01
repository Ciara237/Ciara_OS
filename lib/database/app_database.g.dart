// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalLinkMeta = const VerificationMeta(
    'externalLink',
  );
  @override
  late final GeneratedColumn<String> externalLink = GeneratedColumn<String>(
    'external_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeAllocationDaysMeta =
      const VerificationMeta('timeAllocationDays');
  @override
  late final GeneratedColumn<int> timeAllocationDays = GeneratedColumn<int>(
    'time_allocation_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    domain,
    status,
    nextAction,
    externalLink,
    description,
    timeAllocationDays,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('external_link')) {
      context.handle(
        _externalLinkMeta,
        externalLink.isAcceptableOrUnknown(
          data['external_link']!,
          _externalLinkMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('time_allocation_days')) {
      context.handle(
        _timeAllocationDaysMeta,
        timeAllocationDays.isAcceptableOrUnknown(
          data['time_allocation_days']!,
          _timeAllocationDaysMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      ),
      externalLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_link'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      timeAllocationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_allocation_days'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final String domain;
  final String status;
  final String? nextAction;
  final String? externalLink;
  final String? description;

  /// Project horizon in days — used for milestone / time-remaining calculations.
  final int timeAllocationDays;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Project({
    required this.id,
    required this.name,
    required this.domain,
    required this.status,
    this.nextAction,
    this.externalLink,
    this.description,
    required this.timeAllocationDays,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['domain'] = Variable<String>(domain);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || nextAction != null) {
      map['next_action'] = Variable<String>(nextAction);
    }
    if (!nullToAbsent || externalLink != null) {
      map['external_link'] = Variable<String>(externalLink);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['time_allocation_days'] = Variable<int>(timeAllocationDays);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      domain: Value(domain),
      status: Value(status),
      nextAction: nextAction == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAction),
      externalLink: externalLink == null && nullToAbsent
          ? const Value.absent()
          : Value(externalLink),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      timeAllocationDays: Value(timeAllocationDays),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      domain: serializer.fromJson<String>(json['domain']),
      status: serializer.fromJson<String>(json['status']),
      nextAction: serializer.fromJson<String?>(json['nextAction']),
      externalLink: serializer.fromJson<String?>(json['externalLink']),
      description: serializer.fromJson<String?>(json['description']),
      timeAllocationDays: serializer.fromJson<int>(json['timeAllocationDays']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'domain': serializer.toJson<String>(domain),
      'status': serializer.toJson<String>(status),
      'nextAction': serializer.toJson<String?>(nextAction),
      'externalLink': serializer.toJson<String?>(externalLink),
      'description': serializer.toJson<String?>(description),
      'timeAllocationDays': serializer.toJson<int>(timeAllocationDays),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? domain,
    String? status,
    Value<String?> nextAction = const Value.absent(),
    Value<String?> externalLink = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? timeAllocationDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    domain: domain ?? this.domain,
    status: status ?? this.status,
    nextAction: nextAction.present ? nextAction.value : this.nextAction,
    externalLink: externalLink.present ? externalLink.value : this.externalLink,
    description: description.present ? description.value : this.description,
    timeAllocationDays: timeAllocationDays ?? this.timeAllocationDays,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      domain: data.domain.present ? data.domain.value : this.domain,
      status: data.status.present ? data.status.value : this.status,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      externalLink: data.externalLink.present
          ? data.externalLink.value
          : this.externalLink,
      description: data.description.present
          ? data.description.value
          : this.description,
      timeAllocationDays: data.timeAllocationDays.present
          ? data.timeAllocationDays.value
          : this.timeAllocationDays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('domain: $domain, ')
          ..write('status: $status, ')
          ..write('nextAction: $nextAction, ')
          ..write('externalLink: $externalLink, ')
          ..write('description: $description, ')
          ..write('timeAllocationDays: $timeAllocationDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    domain,
    status,
    nextAction,
    externalLink,
    description,
    timeAllocationDays,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.domain == this.domain &&
          other.status == this.status &&
          other.nextAction == this.nextAction &&
          other.externalLink == this.externalLink &&
          other.description == this.description &&
          other.timeAllocationDays == this.timeAllocationDays &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> domain;
  final Value<String> status;
  final Value<String?> nextAction;
  final Value<String?> externalLink;
  final Value<String?> description;
  final Value<int> timeAllocationDays;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.domain = const Value.absent(),
    this.status = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.externalLink = const Value.absent(),
    this.description = const Value.absent(),
    this.timeAllocationDays = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String domain,
    this.status = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.externalLink = const Value.absent(),
    this.description = const Value.absent(),
    this.timeAllocationDays = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       domain = Value(domain),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? domain,
    Expression<String>? status,
    Expression<String>? nextAction,
    Expression<String>? externalLink,
    Expression<String>? description,
    Expression<int>? timeAllocationDays,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (domain != null) 'domain': domain,
      if (status != null) 'status': status,
      if (nextAction != null) 'next_action': nextAction,
      if (externalLink != null) 'external_link': externalLink,
      if (description != null) 'description': description,
      if (timeAllocationDays != null)
        'time_allocation_days': timeAllocationDays,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? domain,
    Value<String>? status,
    Value<String?>? nextAction,
    Value<String?>? externalLink,
    Value<String?>? description,
    Value<int>? timeAllocationDays,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      domain: domain ?? this.domain,
      status: status ?? this.status,
      nextAction: nextAction ?? this.nextAction,
      externalLink: externalLink ?? this.externalLink,
      description: description ?? this.description,
      timeAllocationDays: timeAllocationDays ?? this.timeAllocationDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (externalLink.present) {
      map['external_link'] = Variable<String>(externalLink.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (timeAllocationDays.present) {
      map['time_allocation_days'] = Variable<int>(timeAllocationDays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('domain: $domain, ')
          ..write('status: $status, ')
          ..write('nextAction: $nextAction, ')
          ..write('externalLink: $externalLink, ')
          ..write('description: $description, ')
          ..write('timeAllocationDays: $timeAllocationDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('notStarted'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _startedMeta = const VerificationMeta(
    'started',
  );
  @override
  late final GeneratedColumn<bool> started = GeneratedColumn<bool>(
    'started',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("started" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _todayMeta = const VerificationMeta('today');
  @override
  late final GeneratedColumn<bool> today = GeneratedColumn<bool>(
    'today',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("today" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postponeCountMeta = const VerificationMeta(
    'postponeCount',
  );
  @override
  late final GeneratedColumn<int> postponeCount = GeneratedColumn<int>(
    'postpone_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    domain,
    status,
    priority,
    started,
    today,
    deadline,
    projectId,
    notes,
    postponeCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('started')) {
      context.handle(
        _startedMeta,
        started.isAcceptableOrUnknown(data['started']!, _startedMeta),
      );
    }
    if (data.containsKey('today')) {
      context.handle(
        _todayMeta,
        today.isAcceptableOrUnknown(data['today']!, _todayMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('postpone_count')) {
      context.handle(
        _postponeCountMeta,
        postponeCount.isAcceptableOrUnknown(
          data['postpone_count']!,
          _postponeCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      started: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}started'],
      )!,
      today: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}today'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      postponeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}postpone_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String domain;
  final String status;
  final String priority;
  final bool started;
  final bool today;
  final DateTime? deadline;
  final int? projectId;
  final String? notes;
  final int postponeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Task({
    required this.id,
    required this.title,
    required this.domain,
    required this.status,
    required this.priority,
    required this.started,
    required this.today,
    this.deadline,
    this.projectId,
    this.notes,
    required this.postponeCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['domain'] = Variable<String>(domain);
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    map['started'] = Variable<bool>(started);
    map['today'] = Variable<bool>(today);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['postpone_count'] = Variable<int>(postponeCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      domain: Value(domain),
      status: Value(status),
      priority: Value(priority),
      started: Value(started),
      today: Value(today),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      postponeCount: Value(postponeCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      domain: serializer.fromJson<String>(json['domain']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      started: serializer.fromJson<bool>(json['started']),
      today: serializer.fromJson<bool>(json['today']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      notes: serializer.fromJson<String?>(json['notes']),
      postponeCount: serializer.fromJson<int>(json['postponeCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'domain': serializer.toJson<String>(domain),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'started': serializer.toJson<bool>(started),
      'today': serializer.toJson<bool>(today),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'projectId': serializer.toJson<int?>(projectId),
      'notes': serializer.toJson<String?>(notes),
      'postponeCount': serializer.toJson<int>(postponeCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? domain,
    String? status,
    String? priority,
    bool? started,
    bool? today,
    Value<DateTime?> deadline = const Value.absent(),
    Value<int?> projectId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? postponeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    domain: domain ?? this.domain,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    started: started ?? this.started,
    today: today ?? this.today,
    deadline: deadline.present ? deadline.value : this.deadline,
    projectId: projectId.present ? projectId.value : this.projectId,
    notes: notes.present ? notes.value : this.notes,
    postponeCount: postponeCount ?? this.postponeCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      domain: data.domain.present ? data.domain.value : this.domain,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      started: data.started.present ? data.started.value : this.started,
      today: data.today.present ? data.today.value : this.today,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      notes: data.notes.present ? data.notes.value : this.notes,
      postponeCount: data.postponeCount.present
          ? data.postponeCount.value
          : this.postponeCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('domain: $domain, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('started: $started, ')
          ..write('today: $today, ')
          ..write('deadline: $deadline, ')
          ..write('projectId: $projectId, ')
          ..write('notes: $notes, ')
          ..write('postponeCount: $postponeCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    domain,
    status,
    priority,
    started,
    today,
    deadline,
    projectId,
    notes,
    postponeCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.domain == this.domain &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.started == this.started &&
          other.today == this.today &&
          other.deadline == this.deadline &&
          other.projectId == this.projectId &&
          other.notes == this.notes &&
          other.postponeCount == this.postponeCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> domain;
  final Value<String> status;
  final Value<String> priority;
  final Value<bool> started;
  final Value<bool> today;
  final Value<DateTime?> deadline;
  final Value<int?> projectId;
  final Value<String?> notes;
  final Value<int> postponeCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.domain = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.started = const Value.absent(),
    this.today = const Value.absent(),
    this.deadline = const Value.absent(),
    this.projectId = const Value.absent(),
    this.notes = const Value.absent(),
    this.postponeCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String domain,
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.started = const Value.absent(),
    this.today = const Value.absent(),
    this.deadline = const Value.absent(),
    this.projectId = const Value.absent(),
    this.notes = const Value.absent(),
    this.postponeCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : title = Value(title),
       domain = Value(domain),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? domain,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<bool>? started,
    Expression<bool>? today,
    Expression<DateTime>? deadline,
    Expression<int>? projectId,
    Expression<String>? notes,
    Expression<int>? postponeCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (domain != null) 'domain': domain,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (started != null) 'started': started,
      if (today != null) 'today': today,
      if (deadline != null) 'deadline': deadline,
      if (projectId != null) 'project_id': projectId,
      if (notes != null) 'notes': notes,
      if (postponeCount != null) 'postpone_count': postponeCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? domain,
    Value<String>? status,
    Value<String>? priority,
    Value<bool>? started,
    Value<bool>? today,
    Value<DateTime?>? deadline,
    Value<int?>? projectId,
    Value<String?>? notes,
    Value<int>? postponeCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      domain: domain ?? this.domain,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      started: started ?? this.started,
      today: today ?? this.today,
      deadline: deadline ?? this.deadline,
      projectId: projectId ?? this.projectId,
      notes: notes ?? this.notes,
      postponeCount: postponeCount ?? this.postponeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (started.present) {
      map['started'] = Variable<bool>(started.value);
    }
    if (today.present) {
      map['today'] = Variable<bool>(today.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (postponeCount.present) {
      map['postpone_count'] = Variable<int>(postponeCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('domain: $domain, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('started: $started, ')
          ..write('today: $today, ')
          ..write('deadline: $deadline, ')
          ..write('projectId: $projectId, ')
          ..write('notes: $notes, ')
          ..write('postponeCount: $postponeCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OpportunitiesTable extends Opportunities
    with TableInfo<$OpportunitiesTable, Opportunity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpportunitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationMeta = const VerificationMeta(
    'organization',
  );
  @override
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
    'organization',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('researching'),
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fitNotesMeta = const VerificationMeta(
    'fitNotes',
  );
  @override
  late final GeneratedColumn<String> fitNotes = GeneratedColumn<String>(
    'fit_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentsMeta = const VerificationMeta(
    'documents',
  );
  @override
  late final GeneratedColumn<String> documents = GeneratedColumn<String>(
    'documents',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentsTotalMeta = const VerificationMeta(
    'documentsTotal',
  );
  @override
  late final GeneratedColumn<int> documentsTotal = GeneratedColumn<int>(
    'documents_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _documentsReadyMeta = const VerificationMeta(
    'documentsReady',
  );
  @override
  late final GeneratedColumn<int> documentsReady = GeneratedColumn<int>(
    'documents_ready',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leadQualityMeta = const VerificationMeta(
    'leadQuality',
  );
  @override
  late final GeneratedColumn<int> leadQuality = GeneratedColumn<int>(
    'lead_quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    organization,
    location,
    type,
    status,
    deadline,
    fitNotes,
    documents,
    documentsTotal,
    documentsReady,
    link,
    leadQuality,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'opportunities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Opportunity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('organization')) {
      context.handle(
        _organizationMeta,
        organization.isAcceptableOrUnknown(
          data['organization']!,
          _organizationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('fit_notes')) {
      context.handle(
        _fitNotesMeta,
        fitNotes.isAcceptableOrUnknown(data['fit_notes']!, _fitNotesMeta),
      );
    }
    if (data.containsKey('documents')) {
      context.handle(
        _documentsMeta,
        documents.isAcceptableOrUnknown(data['documents']!, _documentsMeta),
      );
    }
    if (data.containsKey('documents_total')) {
      context.handle(
        _documentsTotalMeta,
        documentsTotal.isAcceptableOrUnknown(
          data['documents_total']!,
          _documentsTotalMeta,
        ),
      );
    }
    if (data.containsKey('documents_ready')) {
      context.handle(
        _documentsReadyMeta,
        documentsReady.isAcceptableOrUnknown(
          data['documents_ready']!,
          _documentsReadyMeta,
        ),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('lead_quality')) {
      context.handle(
        _leadQualityMeta,
        leadQuality.isAcceptableOrUnknown(
          data['lead_quality']!,
          _leadQualityMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Opportunity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Opportunity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      organization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      fitNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fit_notes'],
      ),
      documents: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}documents'],
      ),
      documentsTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}documents_total'],
      )!,
      documentsReady: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}documents_ready'],
      )!,
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      leadQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lead_quality'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OpportunitiesTable createAlias(String alias) {
    return $OpportunitiesTable(attachedDatabase, alias);
  }
}

class Opportunity extends DataClass implements Insertable<Opportunity> {
  final int id;
  final String title;
  final String organization;
  final String location;
  final String type;
  final String status;
  final DateTime? deadline;
  final String? fitNotes;
  final String? documents;
  final int documentsTotal;
  final int documentsReady;
  final String? link;

  /// 1–3 rating; null = unrated.
  final int? leadQuality;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.location,
    required this.type,
    required this.status,
    this.deadline,
    this.fitNotes,
    this.documents,
    required this.documentsTotal,
    required this.documentsReady,
    this.link,
    this.leadQuality,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['organization'] = Variable<String>(organization);
    map['location'] = Variable<String>(location);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || fitNotes != null) {
      map['fit_notes'] = Variable<String>(fitNotes);
    }
    if (!nullToAbsent || documents != null) {
      map['documents'] = Variable<String>(documents);
    }
    map['documents_total'] = Variable<int>(documentsTotal);
    map['documents_ready'] = Variable<int>(documentsReady);
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    if (!nullToAbsent || leadQuality != null) {
      map['lead_quality'] = Variable<int>(leadQuality);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OpportunitiesCompanion toCompanion(bool nullToAbsent) {
    return OpportunitiesCompanion(
      id: Value(id),
      title: Value(title),
      organization: Value(organization),
      location: Value(location),
      type: Value(type),
      status: Value(status),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      fitNotes: fitNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(fitNotes),
      documents: documents == null && nullToAbsent
          ? const Value.absent()
          : Value(documents),
      documentsTotal: Value(documentsTotal),
      documentsReady: Value(documentsReady),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      leadQuality: leadQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(leadQuality),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Opportunity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Opportunity(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      organization: serializer.fromJson<String>(json['organization']),
      location: serializer.fromJson<String>(json['location']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      fitNotes: serializer.fromJson<String?>(json['fitNotes']),
      documents: serializer.fromJson<String?>(json['documents']),
      documentsTotal: serializer.fromJson<int>(json['documentsTotal']),
      documentsReady: serializer.fromJson<int>(json['documentsReady']),
      link: serializer.fromJson<String?>(json['link']),
      leadQuality: serializer.fromJson<int?>(json['leadQuality']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'organization': serializer.toJson<String>(organization),
      'location': serializer.toJson<String>(location),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'fitNotes': serializer.toJson<String?>(fitNotes),
      'documents': serializer.toJson<String?>(documents),
      'documentsTotal': serializer.toJson<int>(documentsTotal),
      'documentsReady': serializer.toJson<int>(documentsReady),
      'link': serializer.toJson<String?>(link),
      'leadQuality': serializer.toJson<int?>(leadQuality),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Opportunity copyWith({
    int? id,
    String? title,
    String? organization,
    String? location,
    String? type,
    String? status,
    Value<DateTime?> deadline = const Value.absent(),
    Value<String?> fitNotes = const Value.absent(),
    Value<String?> documents = const Value.absent(),
    int? documentsTotal,
    int? documentsReady,
    Value<String?> link = const Value.absent(),
    Value<int?> leadQuality = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Opportunity(
    id: id ?? this.id,
    title: title ?? this.title,
    organization: organization ?? this.organization,
    location: location ?? this.location,
    type: type ?? this.type,
    status: status ?? this.status,
    deadline: deadline.present ? deadline.value : this.deadline,
    fitNotes: fitNotes.present ? fitNotes.value : this.fitNotes,
    documents: documents.present ? documents.value : this.documents,
    documentsTotal: documentsTotal ?? this.documentsTotal,
    documentsReady: documentsReady ?? this.documentsReady,
    link: link.present ? link.value : this.link,
    leadQuality: leadQuality.present ? leadQuality.value : this.leadQuality,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Opportunity copyWithCompanion(OpportunitiesCompanion data) {
    return Opportunity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      location: data.location.present ? data.location.value : this.location,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      fitNotes: data.fitNotes.present ? data.fitNotes.value : this.fitNotes,
      documents: data.documents.present ? data.documents.value : this.documents,
      documentsTotal: data.documentsTotal.present
          ? data.documentsTotal.value
          : this.documentsTotal,
      documentsReady: data.documentsReady.present
          ? data.documentsReady.value
          : this.documentsReady,
      link: data.link.present ? data.link.value : this.link,
      leadQuality: data.leadQuality.present
          ? data.leadQuality.value
          : this.leadQuality,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Opportunity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('organization: $organization, ')
          ..write('location: $location, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('deadline: $deadline, ')
          ..write('fitNotes: $fitNotes, ')
          ..write('documents: $documents, ')
          ..write('documentsTotal: $documentsTotal, ')
          ..write('documentsReady: $documentsReady, ')
          ..write('link: $link, ')
          ..write('leadQuality: $leadQuality, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    organization,
    location,
    type,
    status,
    deadline,
    fitNotes,
    documents,
    documentsTotal,
    documentsReady,
    link,
    leadQuality,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Opportunity &&
          other.id == this.id &&
          other.title == this.title &&
          other.organization == this.organization &&
          other.location == this.location &&
          other.type == this.type &&
          other.status == this.status &&
          other.deadline == this.deadline &&
          other.fitNotes == this.fitNotes &&
          other.documents == this.documents &&
          other.documentsTotal == this.documentsTotal &&
          other.documentsReady == this.documentsReady &&
          other.link == this.link &&
          other.leadQuality == this.leadQuality &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OpportunitiesCompanion extends UpdateCompanion<Opportunity> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> organization;
  final Value<String> location;
  final Value<String> type;
  final Value<String> status;
  final Value<DateTime?> deadline;
  final Value<String?> fitNotes;
  final Value<String?> documents;
  final Value<int> documentsTotal;
  final Value<int> documentsReady;
  final Value<String?> link;
  final Value<int?> leadQuality;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const OpportunitiesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.organization = const Value.absent(),
    this.location = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.deadline = const Value.absent(),
    this.fitNotes = const Value.absent(),
    this.documents = const Value.absent(),
    this.documentsTotal = const Value.absent(),
    this.documentsReady = const Value.absent(),
    this.link = const Value.absent(),
    this.leadQuality = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OpportunitiesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String organization,
    this.location = const Value.absent(),
    required String type,
    this.status = const Value.absent(),
    this.deadline = const Value.absent(),
    this.fitNotes = const Value.absent(),
    this.documents = const Value.absent(),
    this.documentsTotal = const Value.absent(),
    this.documentsReady = const Value.absent(),
    this.link = const Value.absent(),
    this.leadQuality = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : title = Value(title),
       organization = Value(organization),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Opportunity> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? organization,
    Expression<String>? location,
    Expression<String>? type,
    Expression<String>? status,
    Expression<DateTime>? deadline,
    Expression<String>? fitNotes,
    Expression<String>? documents,
    Expression<int>? documentsTotal,
    Expression<int>? documentsReady,
    Expression<String>? link,
    Expression<int>? leadQuality,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (organization != null) 'organization': organization,
      if (location != null) 'location': location,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (deadline != null) 'deadline': deadline,
      if (fitNotes != null) 'fit_notes': fitNotes,
      if (documents != null) 'documents': documents,
      if (documentsTotal != null) 'documents_total': documentsTotal,
      if (documentsReady != null) 'documents_ready': documentsReady,
      if (link != null) 'link': link,
      if (leadQuality != null) 'lead_quality': leadQuality,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OpportunitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? organization,
    Value<String>? location,
    Value<String>? type,
    Value<String>? status,
    Value<DateTime?>? deadline,
    Value<String?>? fitNotes,
    Value<String?>? documents,
    Value<int>? documentsTotal,
    Value<int>? documentsReady,
    Value<String?>? link,
    Value<int?>? leadQuality,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return OpportunitiesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      fitNotes: fitNotes ?? this.fitNotes,
      documents: documents ?? this.documents,
      documentsTotal: documentsTotal ?? this.documentsTotal,
      documentsReady: documentsReady ?? this.documentsReady,
      link: link ?? this.link,
      leadQuality: leadQuality ?? this.leadQuality,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (fitNotes.present) {
      map['fit_notes'] = Variable<String>(fitNotes.value);
    }
    if (documents.present) {
      map['documents'] = Variable<String>(documents.value);
    }
    if (documentsTotal.present) {
      map['documents_total'] = Variable<int>(documentsTotal.value);
    }
    if (documentsReady.present) {
      map['documents_ready'] = Variable<int>(documentsReady.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (leadQuality.present) {
      map['lead_quality'] = Variable<int>(leadQuality.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpportunitiesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('organization: $organization, ')
          ..write('location: $location, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('deadline: $deadline, ')
          ..write('fitNotes: $fitNotes, ')
          ..write('documents: $documents, ')
          ..write('documentsTotal: $documentsTotal, ')
          ..write('documentsReady: $documentsReady, ')
          ..write('link: $link, ')
          ..write('leadQuality: $leadQuality, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WeeklyReviewsTable extends WeeklyReviews
    with TableInfo<$WeeklyReviewsTable, WeeklyReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _weekOfMeta = const VerificationMeta('weekOf');
  @override
  late final GeneratedColumn<DateTime> weekOf = GeneratedColumn<DateTime>(
    'week_of',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whatWorkedMeta = const VerificationMeta(
    'whatWorked',
  );
  @override
  late final GeneratedColumn<String> whatWorked = GeneratedColumn<String>(
    'what_worked',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatFailedMeta = const VerificationMeta(
    'whatFailed',
  );
  @override
  late final GeneratedColumn<String> whatFailed = GeneratedColumn<String>(
    'what_failed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatToAutomateMeta = const VerificationMeta(
    'whatToAutomate',
  );
  @override
  late final GeneratedColumn<String> whatToAutomate = GeneratedColumn<String>(
    'what_to_automate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatToCutMeta = const VerificationMeta(
    'whatToCut',
  );
  @override
  late final GeneratedColumn<String> whatToCut = GeneratedColumn<String>(
    'what_to_cut',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionsMeta = const VerificationMeta(
    'nextActions',
  );
  @override
  late final GeneratedColumn<String> nextActions = GeneratedColumn<String>(
    'next_actions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedRateMeta = const VerificationMeta(
    'startedRate',
  );
  @override
  late final GeneratedColumn<double> startedRate = GeneratedColumn<double>(
    'started_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTasksMeta = const VerificationMeta(
    'totalTasks',
  );
  @override
  late final GeneratedColumn<int> totalTasks = GeneratedColumn<int>(
    'total_tasks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedTasksMeta = const VerificationMeta(
    'startedTasks',
  );
  @override
  late final GeneratedColumn<int> startedTasks = GeneratedColumn<int>(
    'started_tasks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _focusScoreMeta = const VerificationMeta(
    'focusScore',
  );
  @override
  late final GeneratedColumn<double> focusScore = GeneratedColumn<double>(
    'focus_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekOf,
    whatWorked,
    whatFailed,
    whatToAutomate,
    whatToCut,
    nextActions,
    startedRate,
    totalTasks,
    startedTasks,
    focusScore,
    locked,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('week_of')) {
      context.handle(
        _weekOfMeta,
        weekOf.isAcceptableOrUnknown(data['week_of']!, _weekOfMeta),
      );
    } else if (isInserting) {
      context.missing(_weekOfMeta);
    }
    if (data.containsKey('what_worked')) {
      context.handle(
        _whatWorkedMeta,
        whatWorked.isAcceptableOrUnknown(data['what_worked']!, _whatWorkedMeta),
      );
    }
    if (data.containsKey('what_failed')) {
      context.handle(
        _whatFailedMeta,
        whatFailed.isAcceptableOrUnknown(data['what_failed']!, _whatFailedMeta),
      );
    }
    if (data.containsKey('what_to_automate')) {
      context.handle(
        _whatToAutomateMeta,
        whatToAutomate.isAcceptableOrUnknown(
          data['what_to_automate']!,
          _whatToAutomateMeta,
        ),
      );
    }
    if (data.containsKey('what_to_cut')) {
      context.handle(
        _whatToCutMeta,
        whatToCut.isAcceptableOrUnknown(data['what_to_cut']!, _whatToCutMeta),
      );
    }
    if (data.containsKey('next_actions')) {
      context.handle(
        _nextActionsMeta,
        nextActions.isAcceptableOrUnknown(
          data['next_actions']!,
          _nextActionsMeta,
        ),
      );
    }
    if (data.containsKey('started_rate')) {
      context.handle(
        _startedRateMeta,
        startedRate.isAcceptableOrUnknown(
          data['started_rate']!,
          _startedRateMeta,
        ),
      );
    }
    if (data.containsKey('total_tasks')) {
      context.handle(
        _totalTasksMeta,
        totalTasks.isAcceptableOrUnknown(data['total_tasks']!, _totalTasksMeta),
      );
    }
    if (data.containsKey('started_tasks')) {
      context.handle(
        _startedTasksMeta,
        startedTasks.isAcceptableOrUnknown(
          data['started_tasks']!,
          _startedTasksMeta,
        ),
      );
    }
    if (data.containsKey('focus_score')) {
      context.handle(
        _focusScoreMeta,
        focusScore.isAcceptableOrUnknown(data['focus_score']!, _focusScoreMeta),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyReview(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weekOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_of'],
      )!,
      whatWorked: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_worked'],
      ),
      whatFailed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_failed'],
      ),
      whatToAutomate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_to_automate'],
      ),
      whatToCut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_to_cut'],
      ),
      nextActions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_actions'],
      ),
      startedRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}started_rate'],
      ),
      totalTasks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_tasks'],
      )!,
      startedTasks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_tasks'],
      )!,
      focusScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focus_score'],
      ),
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WeeklyReviewsTable createAlias(String alias) {
    return $WeeklyReviewsTable(attachedDatabase, alias);
  }
}

class WeeklyReview extends DataClass implements Insertable<WeeklyReview> {
  final int id;
  final DateTime weekOf;
  final String? whatWorked;
  final String? whatFailed;
  final String? whatToAutomate;
  final String? whatToCut;
  final String? nextActions;
  final double? startedRate;
  final int totalTasks;
  final int startedTasks;
  final double? focusScore;
  final bool locked;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WeeklyReview({
    required this.id,
    required this.weekOf,
    this.whatWorked,
    this.whatFailed,
    this.whatToAutomate,
    this.whatToCut,
    this.nextActions,
    this.startedRate,
    required this.totalTasks,
    required this.startedTasks,
    this.focusScore,
    required this.locked,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['week_of'] = Variable<DateTime>(weekOf);
    if (!nullToAbsent || whatWorked != null) {
      map['what_worked'] = Variable<String>(whatWorked);
    }
    if (!nullToAbsent || whatFailed != null) {
      map['what_failed'] = Variable<String>(whatFailed);
    }
    if (!nullToAbsent || whatToAutomate != null) {
      map['what_to_automate'] = Variable<String>(whatToAutomate);
    }
    if (!nullToAbsent || whatToCut != null) {
      map['what_to_cut'] = Variable<String>(whatToCut);
    }
    if (!nullToAbsent || nextActions != null) {
      map['next_actions'] = Variable<String>(nextActions);
    }
    if (!nullToAbsent || startedRate != null) {
      map['started_rate'] = Variable<double>(startedRate);
    }
    map['total_tasks'] = Variable<int>(totalTasks);
    map['started_tasks'] = Variable<int>(startedTasks);
    if (!nullToAbsent || focusScore != null) {
      map['focus_score'] = Variable<double>(focusScore);
    }
    map['locked'] = Variable<bool>(locked);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeeklyReviewsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyReviewsCompanion(
      id: Value(id),
      weekOf: Value(weekOf),
      whatWorked: whatWorked == null && nullToAbsent
          ? const Value.absent()
          : Value(whatWorked),
      whatFailed: whatFailed == null && nullToAbsent
          ? const Value.absent()
          : Value(whatFailed),
      whatToAutomate: whatToAutomate == null && nullToAbsent
          ? const Value.absent()
          : Value(whatToAutomate),
      whatToCut: whatToCut == null && nullToAbsent
          ? const Value.absent()
          : Value(whatToCut),
      nextActions: nextActions == null && nullToAbsent
          ? const Value.absent()
          : Value(nextActions),
      startedRate: startedRate == null && nullToAbsent
          ? const Value.absent()
          : Value(startedRate),
      totalTasks: Value(totalTasks),
      startedTasks: Value(startedTasks),
      focusScore: focusScore == null && nullToAbsent
          ? const Value.absent()
          : Value(focusScore),
      locked: Value(locked),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeeklyReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyReview(
      id: serializer.fromJson<int>(json['id']),
      weekOf: serializer.fromJson<DateTime>(json['weekOf']),
      whatWorked: serializer.fromJson<String?>(json['whatWorked']),
      whatFailed: serializer.fromJson<String?>(json['whatFailed']),
      whatToAutomate: serializer.fromJson<String?>(json['whatToAutomate']),
      whatToCut: serializer.fromJson<String?>(json['whatToCut']),
      nextActions: serializer.fromJson<String?>(json['nextActions']),
      startedRate: serializer.fromJson<double?>(json['startedRate']),
      totalTasks: serializer.fromJson<int>(json['totalTasks']),
      startedTasks: serializer.fromJson<int>(json['startedTasks']),
      focusScore: serializer.fromJson<double?>(json['focusScore']),
      locked: serializer.fromJson<bool>(json['locked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weekOf': serializer.toJson<DateTime>(weekOf),
      'whatWorked': serializer.toJson<String?>(whatWorked),
      'whatFailed': serializer.toJson<String?>(whatFailed),
      'whatToAutomate': serializer.toJson<String?>(whatToAutomate),
      'whatToCut': serializer.toJson<String?>(whatToCut),
      'nextActions': serializer.toJson<String?>(nextActions),
      'startedRate': serializer.toJson<double?>(startedRate),
      'totalTasks': serializer.toJson<int>(totalTasks),
      'startedTasks': serializer.toJson<int>(startedTasks),
      'focusScore': serializer.toJson<double?>(focusScore),
      'locked': serializer.toJson<bool>(locked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeeklyReview copyWith({
    int? id,
    DateTime? weekOf,
    Value<String?> whatWorked = const Value.absent(),
    Value<String?> whatFailed = const Value.absent(),
    Value<String?> whatToAutomate = const Value.absent(),
    Value<String?> whatToCut = const Value.absent(),
    Value<String?> nextActions = const Value.absent(),
    Value<double?> startedRate = const Value.absent(),
    int? totalTasks,
    int? startedTasks,
    Value<double?> focusScore = const Value.absent(),
    bool? locked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WeeklyReview(
    id: id ?? this.id,
    weekOf: weekOf ?? this.weekOf,
    whatWorked: whatWorked.present ? whatWorked.value : this.whatWorked,
    whatFailed: whatFailed.present ? whatFailed.value : this.whatFailed,
    whatToAutomate: whatToAutomate.present
        ? whatToAutomate.value
        : this.whatToAutomate,
    whatToCut: whatToCut.present ? whatToCut.value : this.whatToCut,
    nextActions: nextActions.present ? nextActions.value : this.nextActions,
    startedRate: startedRate.present ? startedRate.value : this.startedRate,
    totalTasks: totalTasks ?? this.totalTasks,
    startedTasks: startedTasks ?? this.startedTasks,
    focusScore: focusScore.present ? focusScore.value : this.focusScore,
    locked: locked ?? this.locked,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WeeklyReview copyWithCompanion(WeeklyReviewsCompanion data) {
    return WeeklyReview(
      id: data.id.present ? data.id.value : this.id,
      weekOf: data.weekOf.present ? data.weekOf.value : this.weekOf,
      whatWorked: data.whatWorked.present
          ? data.whatWorked.value
          : this.whatWorked,
      whatFailed: data.whatFailed.present
          ? data.whatFailed.value
          : this.whatFailed,
      whatToAutomate: data.whatToAutomate.present
          ? data.whatToAutomate.value
          : this.whatToAutomate,
      whatToCut: data.whatToCut.present ? data.whatToCut.value : this.whatToCut,
      nextActions: data.nextActions.present
          ? data.nextActions.value
          : this.nextActions,
      startedRate: data.startedRate.present
          ? data.startedRate.value
          : this.startedRate,
      totalTasks: data.totalTasks.present
          ? data.totalTasks.value
          : this.totalTasks,
      startedTasks: data.startedTasks.present
          ? data.startedTasks.value
          : this.startedTasks,
      focusScore: data.focusScore.present
          ? data.focusScore.value
          : this.focusScore,
      locked: data.locked.present ? data.locked.value : this.locked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyReview(')
          ..write('id: $id, ')
          ..write('weekOf: $weekOf, ')
          ..write('whatWorked: $whatWorked, ')
          ..write('whatFailed: $whatFailed, ')
          ..write('whatToAutomate: $whatToAutomate, ')
          ..write('whatToCut: $whatToCut, ')
          ..write('nextActions: $nextActions, ')
          ..write('startedRate: $startedRate, ')
          ..write('totalTasks: $totalTasks, ')
          ..write('startedTasks: $startedTasks, ')
          ..write('focusScore: $focusScore, ')
          ..write('locked: $locked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weekOf,
    whatWorked,
    whatFailed,
    whatToAutomate,
    whatToCut,
    nextActions,
    startedRate,
    totalTasks,
    startedTasks,
    focusScore,
    locked,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyReview &&
          other.id == this.id &&
          other.weekOf == this.weekOf &&
          other.whatWorked == this.whatWorked &&
          other.whatFailed == this.whatFailed &&
          other.whatToAutomate == this.whatToAutomate &&
          other.whatToCut == this.whatToCut &&
          other.nextActions == this.nextActions &&
          other.startedRate == this.startedRate &&
          other.totalTasks == this.totalTasks &&
          other.startedTasks == this.startedTasks &&
          other.focusScore == this.focusScore &&
          other.locked == this.locked &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeeklyReviewsCompanion extends UpdateCompanion<WeeklyReview> {
  final Value<int> id;
  final Value<DateTime> weekOf;
  final Value<String?> whatWorked;
  final Value<String?> whatFailed;
  final Value<String?> whatToAutomate;
  final Value<String?> whatToCut;
  final Value<String?> nextActions;
  final Value<double?> startedRate;
  final Value<int> totalTasks;
  final Value<int> startedTasks;
  final Value<double?> focusScore;
  final Value<bool> locked;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WeeklyReviewsCompanion({
    this.id = const Value.absent(),
    this.weekOf = const Value.absent(),
    this.whatWorked = const Value.absent(),
    this.whatFailed = const Value.absent(),
    this.whatToAutomate = const Value.absent(),
    this.whatToCut = const Value.absent(),
    this.nextActions = const Value.absent(),
    this.startedRate = const Value.absent(),
    this.totalTasks = const Value.absent(),
    this.startedTasks = const Value.absent(),
    this.focusScore = const Value.absent(),
    this.locked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeeklyReviewsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime weekOf,
    this.whatWorked = const Value.absent(),
    this.whatFailed = const Value.absent(),
    this.whatToAutomate = const Value.absent(),
    this.whatToCut = const Value.absent(),
    this.nextActions = const Value.absent(),
    this.startedRate = const Value.absent(),
    this.totalTasks = const Value.absent(),
    this.startedTasks = const Value.absent(),
    this.focusScore = const Value.absent(),
    this.locked = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : weekOf = Value(weekOf),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WeeklyReview> custom({
    Expression<int>? id,
    Expression<DateTime>? weekOf,
    Expression<String>? whatWorked,
    Expression<String>? whatFailed,
    Expression<String>? whatToAutomate,
    Expression<String>? whatToCut,
    Expression<String>? nextActions,
    Expression<double>? startedRate,
    Expression<int>? totalTasks,
    Expression<int>? startedTasks,
    Expression<double>? focusScore,
    Expression<bool>? locked,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekOf != null) 'week_of': weekOf,
      if (whatWorked != null) 'what_worked': whatWorked,
      if (whatFailed != null) 'what_failed': whatFailed,
      if (whatToAutomate != null) 'what_to_automate': whatToAutomate,
      if (whatToCut != null) 'what_to_cut': whatToCut,
      if (nextActions != null) 'next_actions': nextActions,
      if (startedRate != null) 'started_rate': startedRate,
      if (totalTasks != null) 'total_tasks': totalTasks,
      if (startedTasks != null) 'started_tasks': startedTasks,
      if (focusScore != null) 'focus_score': focusScore,
      if (locked != null) 'locked': locked,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeeklyReviewsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? weekOf,
    Value<String?>? whatWorked,
    Value<String?>? whatFailed,
    Value<String?>? whatToAutomate,
    Value<String?>? whatToCut,
    Value<String?>? nextActions,
    Value<double?>? startedRate,
    Value<int>? totalTasks,
    Value<int>? startedTasks,
    Value<double?>? focusScore,
    Value<bool>? locked,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WeeklyReviewsCompanion(
      id: id ?? this.id,
      weekOf: weekOf ?? this.weekOf,
      whatWorked: whatWorked ?? this.whatWorked,
      whatFailed: whatFailed ?? this.whatFailed,
      whatToAutomate: whatToAutomate ?? this.whatToAutomate,
      whatToCut: whatToCut ?? this.whatToCut,
      nextActions: nextActions ?? this.nextActions,
      startedRate: startedRate ?? this.startedRate,
      totalTasks: totalTasks ?? this.totalTasks,
      startedTasks: startedTasks ?? this.startedTasks,
      focusScore: focusScore ?? this.focusScore,
      locked: locked ?? this.locked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekOf.present) {
      map['week_of'] = Variable<DateTime>(weekOf.value);
    }
    if (whatWorked.present) {
      map['what_worked'] = Variable<String>(whatWorked.value);
    }
    if (whatFailed.present) {
      map['what_failed'] = Variable<String>(whatFailed.value);
    }
    if (whatToAutomate.present) {
      map['what_to_automate'] = Variable<String>(whatToAutomate.value);
    }
    if (whatToCut.present) {
      map['what_to_cut'] = Variable<String>(whatToCut.value);
    }
    if (nextActions.present) {
      map['next_actions'] = Variable<String>(nextActions.value);
    }
    if (startedRate.present) {
      map['started_rate'] = Variable<double>(startedRate.value);
    }
    if (totalTasks.present) {
      map['total_tasks'] = Variable<int>(totalTasks.value);
    }
    if (startedTasks.present) {
      map['started_tasks'] = Variable<int>(startedTasks.value);
    }
    if (focusScore.present) {
      map['focus_score'] = Variable<double>(focusScore.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyReviewsCompanion(')
          ..write('id: $id, ')
          ..write('weekOf: $weekOf, ')
          ..write('whatWorked: $whatWorked, ')
          ..write('whatFailed: $whatFailed, ')
          ..write('whatToAutomate: $whatToAutomate, ')
          ..write('whatToCut: $whatToCut, ')
          ..write('nextActions: $nextActions, ')
          ..write('startedRate: $startedRate, ')
          ..write('totalTasks: $totalTasks, ')
          ..write('startedTasks: $startedTasks, ')
          ..write('focusScore: $focusScore, ')
          ..write('locked: $locked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $OpportunitiesTable opportunities = $OpportunitiesTable(this);
  late final $WeeklyReviewsTable weeklyReviews = $WeeklyReviewsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    tasks,
    opportunities,
    weeklyReviews,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      required String name,
      required String domain,
      Value<String> status,
      Value<String?> nextAction,
      Value<String?> externalLink,
      Value<String?> description,
      Value<int> timeAllocationDays,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> domain,
      Value<String> status,
      Value<String?> nextAction,
      Value<String?> externalLink,
      Value<String?> description,
      Value<int> timeAllocationDays,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'projects__id__tasks__project_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalLink => $composableBuilder(
    column: $table.externalLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeAllocationDays => $composableBuilder(
    column: $table.timeAllocationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalLink => $composableBuilder(
    column: $table.externalLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeAllocationDays => $composableBuilder(
    column: $table.timeAllocationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalLink => $composableBuilder(
    column: $table.externalLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeAllocationDays => $composableBuilder(
    column: $table.timeAllocationDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({bool tasksRefs})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<String?> externalLink = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> timeAllocationDays = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                domain: domain,
                status: status,
                nextAction: nextAction,
                externalLink: externalLink,
                description: description,
                timeAllocationDays: timeAllocationDays,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String domain,
                Value<String> status = const Value.absent(),
                Value<String?> nextAction = const Value.absent(),
                Value<String?> externalLink = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> timeAllocationDays = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                domain: domain,
                status: status,
                nextAction: nextAction,
                externalLink: externalLink,
                description: description,
                timeAllocationDays: timeAllocationDays,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable, Task>(
                      currentTable: table,
                      referencedTable: $$ProjectsTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProjectsTableReferences(db, table, p0).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({bool tasksRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      required String domain,
      Value<String> status,
      Value<String> priority,
      Value<bool> started,
      Value<bool> today,
      Value<DateTime?> deadline,
      Value<int?> projectId,
      Value<String?> notes,
      Value<int> postponeCount,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> domain,
      Value<String> status,
      Value<String> priority,
      Value<bool> started,
      Value<bool> today,
      Value<DateTime?> deadline,
      Value<int?> projectId,
      Value<String?> notes,
      Value<int> postponeCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('tasks__project_id__projects__id');

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<int>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get started => $composableBuilder(
    column: $table.started,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get today => $composableBuilder(
    column: $table.today,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postponeCount => $composableBuilder(
    column: $table.postponeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get started => $composableBuilder(
    column: $table.started,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get today => $composableBuilder(
    column: $table.today,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postponeCount => $composableBuilder(
    column: $table.postponeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get started =>
      $composableBuilder(column: $table.started, builder: (column) => column);

  GeneratedColumn<bool> get today =>
      $composableBuilder(column: $table.today, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get postponeCount => $composableBuilder(
    column: $table.postponeCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool projectId})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> started = const Value.absent(),
                Value<bool> today = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<int?> projectId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> postponeCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                domain: domain,
                status: status,
                priority: priority,
                started: started,
                today: today,
                deadline: deadline,
                projectId: projectId,
                notes: notes,
                postponeCount: postponeCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String domain,
                Value<String> status = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> started = const Value.absent(),
                Value<bool> today = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<int?> projectId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> postponeCount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                domain: domain,
                status: status,
                priority: priority,
                started: started,
                today: today,
                deadline: deadline,
                projectId: projectId,
                notes: notes,
                postponeCount: postponeCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$TasksTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$OpportunitiesTableCreateCompanionBuilder =
    OpportunitiesCompanion Function({
      Value<int> id,
      required String title,
      required String organization,
      Value<String> location,
      required String type,
      Value<String> status,
      Value<DateTime?> deadline,
      Value<String?> fitNotes,
      Value<String?> documents,
      Value<int> documentsTotal,
      Value<int> documentsReady,
      Value<String?> link,
      Value<int?> leadQuality,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$OpportunitiesTableUpdateCompanionBuilder =
    OpportunitiesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> organization,
      Value<String> location,
      Value<String> type,
      Value<String> status,
      Value<DateTime?> deadline,
      Value<String?> fitNotes,
      Value<String?> documents,
      Value<int> documentsTotal,
      Value<int> documentsReady,
      Value<String?> link,
      Value<int?> leadQuality,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$OpportunitiesTableFilterComposer
    extends Composer<_$AppDatabase, $OpportunitiesTable> {
  $$OpportunitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fitNotes => $composableBuilder(
    column: $table.fitNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documents => $composableBuilder(
    column: $table.documents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get documentsTotal => $composableBuilder(
    column: $table.documentsTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get documentsReady => $composableBuilder(
    column: $table.documentsReady,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leadQuality => $composableBuilder(
    column: $table.leadQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OpportunitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $OpportunitiesTable> {
  $$OpportunitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fitNotes => $composableBuilder(
    column: $table.fitNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documents => $composableBuilder(
    column: $table.documents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get documentsTotal => $composableBuilder(
    column: $table.documentsTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get documentsReady => $composableBuilder(
    column: $table.documentsReady,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leadQuality => $composableBuilder(
    column: $table.leadQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OpportunitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpportunitiesTable> {
  $$OpportunitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get fitNotes =>
      $composableBuilder(column: $table.fitNotes, builder: (column) => column);

  GeneratedColumn<String> get documents =>
      $composableBuilder(column: $table.documents, builder: (column) => column);

  GeneratedColumn<int> get documentsTotal => $composableBuilder(
    column: $table.documentsTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get documentsReady => $composableBuilder(
    column: $table.documentsReady,
    builder: (column) => column,
  );

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<int> get leadQuality => $composableBuilder(
    column: $table.leadQuality,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OpportunitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpportunitiesTable,
          Opportunity,
          $$OpportunitiesTableFilterComposer,
          $$OpportunitiesTableOrderingComposer,
          $$OpportunitiesTableAnnotationComposer,
          $$OpportunitiesTableCreateCompanionBuilder,
          $$OpportunitiesTableUpdateCompanionBuilder,
          (
            Opportunity,
            BaseReferences<_$AppDatabase, $OpportunitiesTable, Opportunity>,
          ),
          Opportunity,
          PrefetchHooks Function()
        > {
  $$OpportunitiesTableTableManager(_$AppDatabase db, $OpportunitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpportunitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpportunitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpportunitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> organization = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String?> fitNotes = const Value.absent(),
                Value<String?> documents = const Value.absent(),
                Value<int> documentsTotal = const Value.absent(),
                Value<int> documentsReady = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<int?> leadQuality = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => OpportunitiesCompanion(
                id: id,
                title: title,
                organization: organization,
                location: location,
                type: type,
                status: status,
                deadline: deadline,
                fitNotes: fitNotes,
                documents: documents,
                documentsTotal: documentsTotal,
                documentsReady: documentsReady,
                link: link,
                leadQuality: leadQuality,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String organization,
                Value<String> location = const Value.absent(),
                required String type,
                Value<String> status = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String?> fitNotes = const Value.absent(),
                Value<String?> documents = const Value.absent(),
                Value<int> documentsTotal = const Value.absent(),
                Value<int> documentsReady = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<int?> leadQuality = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => OpportunitiesCompanion.insert(
                id: id,
                title: title,
                organization: organization,
                location: location,
                type: type,
                status: status,
                deadline: deadline,
                fitNotes: fitNotes,
                documents: documents,
                documentsTotal: documentsTotal,
                documentsReady: documentsReady,
                link: link,
                leadQuality: leadQuality,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OpportunitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpportunitiesTable,
      Opportunity,
      $$OpportunitiesTableFilterComposer,
      $$OpportunitiesTableOrderingComposer,
      $$OpportunitiesTableAnnotationComposer,
      $$OpportunitiesTableCreateCompanionBuilder,
      $$OpportunitiesTableUpdateCompanionBuilder,
      (
        Opportunity,
        BaseReferences<_$AppDatabase, $OpportunitiesTable, Opportunity>,
      ),
      Opportunity,
      PrefetchHooks Function()
    >;
typedef $$WeeklyReviewsTableCreateCompanionBuilder =
    WeeklyReviewsCompanion Function({
      Value<int> id,
      required DateTime weekOf,
      Value<String?> whatWorked,
      Value<String?> whatFailed,
      Value<String?> whatToAutomate,
      Value<String?> whatToCut,
      Value<String?> nextActions,
      Value<double?> startedRate,
      Value<int> totalTasks,
      Value<int> startedTasks,
      Value<double?> focusScore,
      Value<bool> locked,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WeeklyReviewsTableUpdateCompanionBuilder =
    WeeklyReviewsCompanion Function({
      Value<int> id,
      Value<DateTime> weekOf,
      Value<String?> whatWorked,
      Value<String?> whatFailed,
      Value<String?> whatToAutomate,
      Value<String?> whatToCut,
      Value<String?> nextActions,
      Value<double?> startedRate,
      Value<int> totalTasks,
      Value<int> startedTasks,
      Value<double?> focusScore,
      Value<bool> locked,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$WeeklyReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyReviewsTable> {
  $$WeeklyReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get weekOf => $composableBuilder(
    column: $table.weekOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatWorked => $composableBuilder(
    column: $table.whatWorked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatFailed => $composableBuilder(
    column: $table.whatFailed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatToAutomate => $composableBuilder(
    column: $table.whatToAutomate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatToCut => $composableBuilder(
    column: $table.whatToCut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextActions => $composableBuilder(
    column: $table.nextActions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startedRate => $composableBuilder(
    column: $table.startedRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTasks => $composableBuilder(
    column: $table.totalTasks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedTasks => $composableBuilder(
    column: $table.startedTasks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focusScore => $composableBuilder(
    column: $table.focusScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyReviewsTable> {
  $$WeeklyReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get weekOf => $composableBuilder(
    column: $table.weekOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatWorked => $composableBuilder(
    column: $table.whatWorked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatFailed => $composableBuilder(
    column: $table.whatFailed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatToAutomate => $composableBuilder(
    column: $table.whatToAutomate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatToCut => $composableBuilder(
    column: $table.whatToCut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextActions => $composableBuilder(
    column: $table.nextActions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startedRate => $composableBuilder(
    column: $table.startedRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTasks => $composableBuilder(
    column: $table.totalTasks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedTasks => $composableBuilder(
    column: $table.startedTasks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focusScore => $composableBuilder(
    column: $table.focusScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyReviewsTable> {
  $$WeeklyReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get weekOf =>
      $composableBuilder(column: $table.weekOf, builder: (column) => column);

  GeneratedColumn<String> get whatWorked => $composableBuilder(
    column: $table.whatWorked,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatFailed => $composableBuilder(
    column: $table.whatFailed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatToAutomate => $composableBuilder(
    column: $table.whatToAutomate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatToCut =>
      $composableBuilder(column: $table.whatToCut, builder: (column) => column);

  GeneratedColumn<String> get nextActions => $composableBuilder(
    column: $table.nextActions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startedRate => $composableBuilder(
    column: $table.startedRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTasks => $composableBuilder(
    column: $table.totalTasks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedTasks => $composableBuilder(
    column: $table.startedTasks,
    builder: (column) => column,
  );

  GeneratedColumn<double> get focusScore => $composableBuilder(
    column: $table.focusScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeeklyReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyReviewsTable,
          WeeklyReview,
          $$WeeklyReviewsTableFilterComposer,
          $$WeeklyReviewsTableOrderingComposer,
          $$WeeklyReviewsTableAnnotationComposer,
          $$WeeklyReviewsTableCreateCompanionBuilder,
          $$WeeklyReviewsTableUpdateCompanionBuilder,
          (
            WeeklyReview,
            BaseReferences<_$AppDatabase, $WeeklyReviewsTable, WeeklyReview>,
          ),
          WeeklyReview,
          PrefetchHooks Function()
        > {
  $$WeeklyReviewsTableTableManager(_$AppDatabase db, $WeeklyReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> weekOf = const Value.absent(),
                Value<String?> whatWorked = const Value.absent(),
                Value<String?> whatFailed = const Value.absent(),
                Value<String?> whatToAutomate = const Value.absent(),
                Value<String?> whatToCut = const Value.absent(),
                Value<String?> nextActions = const Value.absent(),
                Value<double?> startedRate = const Value.absent(),
                Value<int> totalTasks = const Value.absent(),
                Value<int> startedTasks = const Value.absent(),
                Value<double?> focusScore = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeeklyReviewsCompanion(
                id: id,
                weekOf: weekOf,
                whatWorked: whatWorked,
                whatFailed: whatFailed,
                whatToAutomate: whatToAutomate,
                whatToCut: whatToCut,
                nextActions: nextActions,
                startedRate: startedRate,
                totalTasks: totalTasks,
                startedTasks: startedTasks,
                focusScore: focusScore,
                locked: locked,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime weekOf,
                Value<String?> whatWorked = const Value.absent(),
                Value<String?> whatFailed = const Value.absent(),
                Value<String?> whatToAutomate = const Value.absent(),
                Value<String?> whatToCut = const Value.absent(),
                Value<String?> nextActions = const Value.absent(),
                Value<double?> startedRate = const Value.absent(),
                Value<int> totalTasks = const Value.absent(),
                Value<int> startedTasks = const Value.absent(),
                Value<double?> focusScore = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WeeklyReviewsCompanion.insert(
                id: id,
                weekOf: weekOf,
                whatWorked: whatWorked,
                whatFailed: whatFailed,
                whatToAutomate: whatToAutomate,
                whatToCut: whatToCut,
                nextActions: nextActions,
                startedRate: startedRate,
                totalTasks: totalTasks,
                startedTasks: startedTasks,
                focusScore: focusScore,
                locked: locked,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyReviewsTable,
      WeeklyReview,
      $$WeeklyReviewsTableFilterComposer,
      $$WeeklyReviewsTableOrderingComposer,
      $$WeeklyReviewsTableAnnotationComposer,
      $$WeeklyReviewsTableCreateCompanionBuilder,
      $$WeeklyReviewsTableUpdateCompanionBuilder,
      (
        WeeklyReview,
        BaseReferences<_$AppDatabase, $WeeklyReviewsTable, WeeklyReview>,
      ),
      WeeklyReview,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$OpportunitiesTableTableManager get opportunities =>
      $$OpportunitiesTableTableManager(_db, _db.opportunities);
  $$WeeklyReviewsTableTableManager get weeklyReviews =>
      $$WeeklyReviewsTableTableManager(_db, _db.weeklyReviews);
}
