// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChildrenTable extends Children
    with TableInfo<$ChildrenTable, ChildrenData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildrenTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    birthDate,
    colorValue,
    photoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'children';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChildrenData> instance, {
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
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildrenData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildrenData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChildrenTable createAlias(String alias) {
    return $ChildrenTable(attachedDatabase, alias);
  }
}

class ChildrenData extends DataClass implements Insertable<ChildrenData> {
  final int id;
  final String name;
  final DateTime birthDate;
  final int colorValue;
  final String? photoPath;
  final DateTime createdAt;
  const ChildrenData({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.colorValue,
    this.photoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['birth_date'] = Variable<DateTime>(birthDate);
    map['color_value'] = Variable<int>(colorValue);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChildrenCompanion toCompanion(bool nullToAbsent) {
    return ChildrenCompanion(
      id: Value(id),
      name: Value(name),
      birthDate: Value(birthDate),
      colorValue: Value(colorValue),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory ChildrenData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildrenData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'colorValue': serializer.toJson<int>(colorValue),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChildrenData copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    int? colorValue,
    Value<String?> photoPath = const Value.absent(),
    DateTime? createdAt,
  }) => ChildrenData(
    id: id ?? this.id,
    name: name ?? this.name,
    birthDate: birthDate ?? this.birthDate,
    colorValue: colorValue ?? this.colorValue,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  ChildrenData copyWithCompanion(ChildrenCompanion data) {
    return ChildrenData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('colorValue: $colorValue, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, birthDate, colorValue, photoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildrenData &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthDate == this.birthDate &&
          other.colorValue == this.colorValue &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class ChildrenCompanion extends UpdateCompanion<ChildrenData> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> birthDate;
  final Value<int> colorValue;
  final Value<String?> photoPath;
  final Value<DateTime> createdAt;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChildrenCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime birthDate,
    required int colorValue,
    this.photoPath = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       birthDate = Value(birthDate),
       colorValue = Value(colorValue),
       createdAt = Value(createdAt);
  static Insertable<ChildrenData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<int>? colorValue,
    Expression<String>? photoPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (colorValue != null) 'color_value': colorValue,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChildrenCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? birthDate,
    Value<int>? colorValue,
    Value<String?>? photoPath,
    Value<DateTime>? createdAt,
  }) {
    return ChildrenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      colorValue: colorValue ?? this.colorValue,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
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
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('colorValue: $colorValue, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PreventiveTasksTable extends PreventiveTasks
    with TableInfo<$PreventiveTasksTable, PreventiveTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreventiveTasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _recommendedDateMeta = const VerificationMeta(
    'recommendedDate',
  );
  @override
  late final GeneratedColumn<DateTime> recommendedDate =
      GeneratedColumn<DateTime>(
        'recommended_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedDateMeta = const VerificationMeta(
    'completedDate',
  );
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>(
        'completed_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    type,
    title,
    recommendedDate,
    status,
    completedDate,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preventive_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreventiveTaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('recommended_date')) {
      context.handle(
        _recommendedDateMeta,
        recommendedDate.isAcceptableOrUnknown(
          data['recommended_date']!,
          _recommendedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_date')) {
      context.handle(
        _completedDateMeta,
        completedDate.isAcceptableOrUnknown(
          data['completed_date']!,
          _completedDateMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreventiveTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreventiveTaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      recommendedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recommended_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      completedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PreventiveTasksTable createAlias(String alias) {
    return $PreventiveTasksTable(attachedDatabase, alias);
  }
}

class PreventiveTaskRow extends DataClass
    implements Insertable<PreventiveTaskRow> {
  final int id;
  final int childId;
  final int type;
  final String title;
  final DateTime recommendedDate;
  final int status;
  final DateTime? completedDate;
  final String? note;
  const PreventiveTaskRow({
    required this.id,
    required this.childId,
    required this.type,
    required this.title,
    required this.recommendedDate,
    required this.status,
    this.completedDate,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['type'] = Variable<int>(type);
    map['title'] = Variable<String>(title);
    map['recommended_date'] = Variable<DateTime>(recommendedDate);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || completedDate != null) {
      map['completed_date'] = Variable<DateTime>(completedDate);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PreventiveTasksCompanion toCompanion(bool nullToAbsent) {
    return PreventiveTasksCompanion(
      id: Value(id),
      childId: Value(childId),
      type: Value(type),
      title: Value(title),
      recommendedDate: Value(recommendedDate),
      status: Value(status),
      completedDate: completedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory PreventiveTaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreventiveTaskRow(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      type: serializer.fromJson<int>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      recommendedDate: serializer.fromJson<DateTime>(json['recommendedDate']),
      status: serializer.fromJson<int>(json['status']),
      completedDate: serializer.fromJson<DateTime?>(json['completedDate']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'type': serializer.toJson<int>(type),
      'title': serializer.toJson<String>(title),
      'recommendedDate': serializer.toJson<DateTime>(recommendedDate),
      'status': serializer.toJson<int>(status),
      'completedDate': serializer.toJson<DateTime?>(completedDate),
      'note': serializer.toJson<String?>(note),
    };
  }

  PreventiveTaskRow copyWith({
    int? id,
    int? childId,
    int? type,
    String? title,
    DateTime? recommendedDate,
    int? status,
    Value<DateTime?> completedDate = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => PreventiveTaskRow(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    type: type ?? this.type,
    title: title ?? this.title,
    recommendedDate: recommendedDate ?? this.recommendedDate,
    status: status ?? this.status,
    completedDate: completedDate.present
        ? completedDate.value
        : this.completedDate,
    note: note.present ? note.value : this.note,
  );
  PreventiveTaskRow copyWithCompanion(PreventiveTasksCompanion data) {
    return PreventiveTaskRow(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      recommendedDate: data.recommendedDate.present
          ? data.recommendedDate.value
          : this.recommendedDate,
      status: data.status.present ? data.status.value : this.status,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreventiveTaskRow(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('recommendedDate: $recommendedDate, ')
          ..write('status: $status, ')
          ..write('completedDate: $completedDate, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    type,
    title,
    recommendedDate,
    status,
    completedDate,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreventiveTaskRow &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.type == this.type &&
          other.title == this.title &&
          other.recommendedDate == this.recommendedDate &&
          other.status == this.status &&
          other.completedDate == this.completedDate &&
          other.note == this.note);
}

class PreventiveTasksCompanion extends UpdateCompanion<PreventiveTaskRow> {
  final Value<int> id;
  final Value<int> childId;
  final Value<int> type;
  final Value<String> title;
  final Value<DateTime> recommendedDate;
  final Value<int> status;
  final Value<DateTime?> completedDate;
  final Value<String?> note;
  const PreventiveTasksCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.recommendedDate = const Value.absent(),
    this.status = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.note = const Value.absent(),
  });
  PreventiveTasksCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required int type,
    required String title,
    required DateTime recommendedDate,
    required int status,
    this.completedDate = const Value.absent(),
    this.note = const Value.absent(),
  }) : childId = Value(childId),
       type = Value(type),
       title = Value(title),
       recommendedDate = Value(recommendedDate),
       status = Value(status);
  static Insertable<PreventiveTaskRow> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<int>? type,
    Expression<String>? title,
    Expression<DateTime>? recommendedDate,
    Expression<int>? status,
    Expression<DateTime>? completedDate,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (recommendedDate != null) 'recommended_date': recommendedDate,
      if (status != null) 'status': status,
      if (completedDate != null) 'completed_date': completedDate,
      if (note != null) 'note': note,
    });
  }

  PreventiveTasksCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<int>? type,
    Value<String>? title,
    Value<DateTime>? recommendedDate,
    Value<int>? status,
    Value<DateTime?>? completedDate,
    Value<String?>? note,
  }) {
    return PreventiveTasksCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      type: type ?? this.type,
      title: title ?? this.title,
      recommendedDate: recommendedDate ?? this.recommendedDate,
      status: status ?? this.status,
      completedDate: completedDate ?? this.completedDate,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (recommendedDate.present) {
      map['recommended_date'] = Variable<DateTime>(recommendedDate.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreventiveTasksCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('recommendedDate: $recommendedDate, ')
          ..write('status: $status, ')
          ..write('completedDate: $completedDate, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $CheckupRecordsTable extends CheckupRecords
    with TableInfo<$CheckupRecordsTable, CheckupRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckupRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clinicNameMeta = const VerificationMeta(
    'clinicName',
  );
  @override
  late final GeneratedColumn<String> clinicName = GeneratedColumn<String>(
    'clinic_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, childId, date, clinicName, memo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkup_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckupRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('clinic_name')) {
      context.handle(
        _clinicNameMeta,
        clinicName.isAcceptableOrUnknown(data['clinic_name']!, _clinicNameMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CheckupRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckupRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      clinicName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic_name'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
    );
  }

  @override
  $CheckupRecordsTable createAlias(String alias) {
    return $CheckupRecordsTable(attachedDatabase, alias);
  }
}

class CheckupRecordRow extends DataClass
    implements Insertable<CheckupRecordRow> {
  final int id;
  final int childId;
  final DateTime date;
  final String? clinicName;
  final String? memo;
  const CheckupRecordRow({
    required this.id,
    required this.childId,
    required this.date,
    this.clinicName,
    this.memo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || clinicName != null) {
      map['clinic_name'] = Variable<String>(clinicName);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  CheckupRecordsCompanion toCompanion(bool nullToAbsent) {
    return CheckupRecordsCompanion(
      id: Value(id),
      childId: Value(childId),
      date: Value(date),
      clinicName: clinicName == null && nullToAbsent
          ? const Value.absent()
          : Value(clinicName),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory CheckupRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckupRecordRow(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      date: serializer.fromJson<DateTime>(json['date']),
      clinicName: serializer.fromJson<String?>(json['clinicName']),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'date': serializer.toJson<DateTime>(date),
      'clinicName': serializer.toJson<String?>(clinicName),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  CheckupRecordRow copyWith({
    int? id,
    int? childId,
    DateTime? date,
    Value<String?> clinicName = const Value.absent(),
    Value<String?> memo = const Value.absent(),
  }) => CheckupRecordRow(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    date: date ?? this.date,
    clinicName: clinicName.present ? clinicName.value : this.clinicName,
    memo: memo.present ? memo.value : this.memo,
  );
  CheckupRecordRow copyWithCompanion(CheckupRecordsCompanion data) {
    return CheckupRecordRow(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      date: data.date.present ? data.date.value : this.date,
      clinicName: data.clinicName.present
          ? data.clinicName.value
          : this.clinicName,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckupRecordRow(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('date: $date, ')
          ..write('clinicName: $clinicName, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, date, clinicName, memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckupRecordRow &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.date == this.date &&
          other.clinicName == this.clinicName &&
          other.memo == this.memo);
}

class CheckupRecordsCompanion extends UpdateCompanion<CheckupRecordRow> {
  final Value<int> id;
  final Value<int> childId;
  final Value<DateTime> date;
  final Value<String?> clinicName;
  final Value<String?> memo;
  const CheckupRecordsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.date = const Value.absent(),
    this.clinicName = const Value.absent(),
    this.memo = const Value.absent(),
  });
  CheckupRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required DateTime date,
    this.clinicName = const Value.absent(),
    this.memo = const Value.absent(),
  }) : childId = Value(childId),
       date = Value(date);
  static Insertable<CheckupRecordRow> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<DateTime>? date,
    Expression<String>? clinicName,
    Expression<String>? memo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (date != null) 'date': date,
      if (clinicName != null) 'clinic_name': clinicName,
      if (memo != null) 'memo': memo,
    });
  }

  CheckupRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<DateTime>? date,
    Value<String?>? clinicName,
    Value<String?>? memo,
  }) {
    return CheckupRecordsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      clinicName: clinicName ?? this.clinicName,
      memo: memo ?? this.memo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (clinicName.present) {
      map['clinic_name'] = Variable<String>(clinicName.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckupRecordsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('date: $date, ')
          ..write('clinicName: $clinicName, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }
}

class $ToothRecordsTable extends ToothRecords
    with TableInfo<$ToothRecordsTable, ToothRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToothRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _toothCodeMeta = const VerificationMeta(
    'toothCode',
  );
  @override
  late final GeneratedColumn<int> toothCode = GeneratedColumn<int>(
    'tooth_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    childId,
    toothCode,
    status,
    note,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tooth_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ToothRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('tooth_code')) {
      context.handle(
        _toothCodeMeta,
        toothCode.isAcceptableOrUnknown(data['tooth_code']!, _toothCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_toothCodeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {childId, toothCode},
  ];
  @override
  ToothRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ToothRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      toothCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tooth_code'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ToothRecordsTable createAlias(String alias) {
    return $ToothRecordsTable(attachedDatabase, alias);
  }
}

class ToothRecordRow extends DataClass implements Insertable<ToothRecordRow> {
  final int id;
  final int childId;
  final int toothCode;
  final int status;
  final String? note;
  final DateTime updatedAt;
  const ToothRecordRow({
    required this.id,
    required this.childId,
    required this.toothCode,
    required this.status,
    this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['tooth_code'] = Variable<int>(toothCode);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ToothRecordsCompanion toCompanion(bool nullToAbsent) {
    return ToothRecordsCompanion(
      id: Value(id),
      childId: Value(childId),
      toothCode: Value(toothCode),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory ToothRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ToothRecordRow(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      toothCode: serializer.fromJson<int>(json['toothCode']),
      status: serializer.fromJson<int>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'toothCode': serializer.toJson<int>(toothCode),
      'status': serializer.toJson<int>(status),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ToothRecordRow copyWith({
    int? id,
    int? childId,
    int? toothCode,
    int? status,
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
  }) => ToothRecordRow(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    toothCode: toothCode ?? this.toothCode,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ToothRecordRow copyWithCompanion(ToothRecordsCompanion data) {
    return ToothRecordRow(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      toothCode: data.toothCode.present ? data.toothCode.value : this.toothCode,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ToothRecordRow(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('toothCode: $toothCode, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childId, toothCode, status, note, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToothRecordRow &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.toothCode == this.toothCode &&
          other.status == this.status &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class ToothRecordsCompanion extends UpdateCompanion<ToothRecordRow> {
  final Value<int> id;
  final Value<int> childId;
  final Value<int> toothCode;
  final Value<int> status;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  const ToothRecordsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.toothCode = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ToothRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required int toothCode,
    required int status,
    this.note = const Value.absent(),
    required DateTime updatedAt,
  }) : childId = Value(childId),
       toothCode = Value(toothCode),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<ToothRecordRow> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<int>? toothCode,
    Expression<int>? status,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (toothCode != null) 'tooth_code': toothCode,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ToothRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<int>? toothCode,
    Value<int>? status,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
  }) {
    return ToothRecordsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      toothCode: toothCode ?? this.toothCode,
      status: status ?? this.status,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (toothCode.present) {
      map['tooth_code'] = Variable<int>(toothCode.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToothRecordsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('toothCode: $toothCode, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $PreventiveTasksTable preventiveTasks = $PreventiveTasksTable(
    this,
  );
  late final $CheckupRecordsTable checkupRecords = $CheckupRecordsTable(this);
  late final $ToothRecordsTable toothRecords = $ToothRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    children,
    preventiveTasks,
    checkupRecords,
    toothRecords,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('preventive_tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('checkup_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tooth_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ChildrenTableCreateCompanionBuilder =
    ChildrenCompanion Function({
      Value<int> id,
      required String name,
      required DateTime birthDate,
      required int colorValue,
      Value<String?> photoPath,
      required DateTime createdAt,
    });
typedef $$ChildrenTableUpdateCompanionBuilder =
    ChildrenCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> birthDate,
      Value<int> colorValue,
      Value<String?> photoPath,
      Value<DateTime> createdAt,
    });

final class $$ChildrenTableReferences
    extends BaseReferences<_$AppDatabase, $ChildrenTable, ChildrenData> {
  $$ChildrenTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PreventiveTasksTable, List<PreventiveTaskRow>>
  _preventiveTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.preventiveTasks,
    aliasName: 'children__id__preventive_tasks__child_id',
  );

  $$PreventiveTasksTableProcessedTableManager get preventiveTasksRefs {
    final manager = $$PreventiveTasksTableTableManager(
      $_db,
      $_db.preventiveTasks,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _preventiveTasksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CheckupRecordsTable, List<CheckupRecordRow>>
  _checkupRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.checkupRecords,
    aliasName: 'children__id__checkup_records__child_id',
  );

  $$CheckupRecordsTableProcessedTableManager get checkupRecordsRefs {
    final manager = $$CheckupRecordsTableTableManager(
      $_db,
      $_db.checkupRecords,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkupRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ToothRecordsTable, List<ToothRecordRow>>
  _toothRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.toothRecords,
    aliasName: 'children__id__tooth_records__child_id',
  );

  $$ToothRecordsTableProcessedTableManager get toothRecordsRefs {
    final manager = $$ToothRecordsTableTableManager(
      $_db,
      $_db.toothRecords,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_toothRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChildrenTableFilterComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableFilterComposer({
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

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> preventiveTasksRefs(
    Expression<bool> Function($$PreventiveTasksTableFilterComposer f) f,
  ) {
    final $$PreventiveTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preventiveTasks,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreventiveTasksTableFilterComposer(
            $db: $db,
            $table: $db.preventiveTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> checkupRecordsRefs(
    Expression<bool> Function($$CheckupRecordsTableFilterComposer f) f,
  ) {
    final $$CheckupRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkupRecords,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckupRecordsTableFilterComposer(
            $db: $db,
            $table: $db.checkupRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> toothRecordsRefs(
    Expression<bool> Function($$ToothRecordsTableFilterComposer f) f,
  ) {
    final $$ToothRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.toothRecords,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ToothRecordsTableFilterComposer(
            $db: $db,
            $table: $db.toothRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChildrenTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableOrderingComposer({
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

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildrenTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> preventiveTasksRefs<T extends Object>(
    Expression<T> Function($$PreventiveTasksTableAnnotationComposer a) f,
  ) {
    final $$PreventiveTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preventiveTasks,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreventiveTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.preventiveTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> checkupRecordsRefs<T extends Object>(
    Expression<T> Function($$CheckupRecordsTableAnnotationComposer a) f,
  ) {
    final $$CheckupRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkupRecords,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckupRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkupRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> toothRecordsRefs<T extends Object>(
    Expression<T> Function($$ToothRecordsTableAnnotationComposer a) f,
  ) {
    final $$ToothRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.toothRecords,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ToothRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.toothRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChildrenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChildrenTable,
          ChildrenData,
          $$ChildrenTableFilterComposer,
          $$ChildrenTableOrderingComposer,
          $$ChildrenTableAnnotationComposer,
          $$ChildrenTableCreateCompanionBuilder,
          $$ChildrenTableUpdateCompanionBuilder,
          (ChildrenData, $$ChildrenTableReferences),
          ChildrenData,
          PrefetchHooks Function({
            bool preventiveTasksRefs,
            bool checkupRecordsRefs,
            bool toothRecordsRefs,
          })
        > {
  $$ChildrenTableTableManager(_$AppDatabase db, $ChildrenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChildrenCompanion(
                id: id,
                name: name,
                birthDate: birthDate,
                colorValue: colorValue,
                photoPath: photoPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime birthDate,
                required int colorValue,
                Value<String?> photoPath = const Value.absent(),
                required DateTime createdAt,
              }) => ChildrenCompanion.insert(
                id: id,
                name: name,
                birthDate: birthDate,
                colorValue: colorValue,
                photoPath: photoPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChildrenTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                preventiveTasksRefs = false,
                checkupRecordsRefs = false,
                toothRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (preventiveTasksRefs) db.preventiveTasks,
                    if (checkupRecordsRefs) db.checkupRecords,
                    if (toothRecordsRefs) db.toothRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (preventiveTasksRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          PreventiveTaskRow
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._preventiveTasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).preventiveTasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (checkupRecordsRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          CheckupRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._checkupRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).checkupRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (toothRecordsRefs)
                        await $_getPrefetchedData<
                          ChildrenData,
                          $ChildrenTable,
                          ToothRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._toothRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).toothRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChildrenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChildrenTable,
      ChildrenData,
      $$ChildrenTableFilterComposer,
      $$ChildrenTableOrderingComposer,
      $$ChildrenTableAnnotationComposer,
      $$ChildrenTableCreateCompanionBuilder,
      $$ChildrenTableUpdateCompanionBuilder,
      (ChildrenData, $$ChildrenTableReferences),
      ChildrenData,
      PrefetchHooks Function({
        bool preventiveTasksRefs,
        bool checkupRecordsRefs,
        bool toothRecordsRefs,
      })
    >;
typedef $$PreventiveTasksTableCreateCompanionBuilder =
    PreventiveTasksCompanion Function({
      Value<int> id,
      required int childId,
      required int type,
      required String title,
      required DateTime recommendedDate,
      required int status,
      Value<DateTime?> completedDate,
      Value<String?> note,
    });
typedef $$PreventiveTasksTableUpdateCompanionBuilder =
    PreventiveTasksCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<int> type,
      Value<String> title,
      Value<DateTime> recommendedDate,
      Value<int> status,
      Value<DateTime?> completedDate,
      Value<String?> note,
    });

final class $$PreventiveTasksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PreventiveTasksTable,
          PreventiveTaskRow
        > {
  $$PreventiveTasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('preventive_tasks__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PreventiveTasksTableFilterComposer
    extends Composer<_$AppDatabase, $PreventiveTasksTable> {
  $$PreventiveTasksTableFilterComposer({
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

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recommendedDate => $composableBuilder(
    column: $table.recommendedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreventiveTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $PreventiveTasksTable> {
  $$PreventiveTasksTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recommendedDate => $composableBuilder(
    column: $table.recommendedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreventiveTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreventiveTasksTable> {
  $$PreventiveTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get recommendedDate => $composableBuilder(
    column: $table.recommendedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreventiveTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreventiveTasksTable,
          PreventiveTaskRow,
          $$PreventiveTasksTableFilterComposer,
          $$PreventiveTasksTableOrderingComposer,
          $$PreventiveTasksTableAnnotationComposer,
          $$PreventiveTasksTableCreateCompanionBuilder,
          $$PreventiveTasksTableUpdateCompanionBuilder,
          (PreventiveTaskRow, $$PreventiveTasksTableReferences),
          PreventiveTaskRow,
          PrefetchHooks Function({bool childId})
        > {
  $$PreventiveTasksTableTableManager(
    _$AppDatabase db,
    $PreventiveTasksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreventiveTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreventiveTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreventiveTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> recommendedDate = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime?> completedDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => PreventiveTasksCompanion(
                id: id,
                childId: childId,
                type: type,
                title: title,
                recommendedDate: recommendedDate,
                status: status,
                completedDate: completedDate,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required int type,
                required String title,
                required DateTime recommendedDate,
                required int status,
                Value<DateTime?> completedDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => PreventiveTasksCompanion.insert(
                id: id,
                childId: childId,
                type: type,
                title: title,
                recommendedDate: recommendedDate,
                status: status,
                completedDate: completedDate,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PreventiveTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable:
                                    $$PreventiveTasksTableReferences
                                        ._childIdTable(db),
                                referencedColumn:
                                    $$PreventiveTasksTableReferences
                                        ._childIdTable(db)
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

typedef $$PreventiveTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreventiveTasksTable,
      PreventiveTaskRow,
      $$PreventiveTasksTableFilterComposer,
      $$PreventiveTasksTableOrderingComposer,
      $$PreventiveTasksTableAnnotationComposer,
      $$PreventiveTasksTableCreateCompanionBuilder,
      $$PreventiveTasksTableUpdateCompanionBuilder,
      (PreventiveTaskRow, $$PreventiveTasksTableReferences),
      PreventiveTaskRow,
      PrefetchHooks Function({bool childId})
    >;
typedef $$CheckupRecordsTableCreateCompanionBuilder =
    CheckupRecordsCompanion Function({
      Value<int> id,
      required int childId,
      required DateTime date,
      Value<String?> clinicName,
      Value<String?> memo,
    });
typedef $$CheckupRecordsTableUpdateCompanionBuilder =
    CheckupRecordsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<DateTime> date,
      Value<String?> clinicName,
      Value<String?> memo,
    });

final class $$CheckupRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CheckupRecordsTable, CheckupRecordRow> {
  $$CheckupRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('checkup_records__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CheckupRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckupRecordsTable> {
  $$CheckupRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckupRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckupRecordsTable> {
  $$CheckupRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckupRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckupRecordsTable> {
  $$CheckupRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get clinicName => $composableBuilder(
    column: $table.clinicName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckupRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckupRecordsTable,
          CheckupRecordRow,
          $$CheckupRecordsTableFilterComposer,
          $$CheckupRecordsTableOrderingComposer,
          $$CheckupRecordsTableAnnotationComposer,
          $$CheckupRecordsTableCreateCompanionBuilder,
          $$CheckupRecordsTableUpdateCompanionBuilder,
          (CheckupRecordRow, $$CheckupRecordsTableReferences),
          CheckupRecordRow,
          PrefetchHooks Function({bool childId})
        > {
  $$CheckupRecordsTableTableManager(
    _$AppDatabase db,
    $CheckupRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckupRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckupRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckupRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> clinicName = const Value.absent(),
                Value<String?> memo = const Value.absent(),
              }) => CheckupRecordsCompanion(
                id: id,
                childId: childId,
                date: date,
                clinicName: clinicName,
                memo: memo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required DateTime date,
                Value<String?> clinicName = const Value.absent(),
                Value<String?> memo = const Value.absent(),
              }) => CheckupRecordsCompanion.insert(
                id: id,
                childId: childId,
                date: date,
                clinicName: clinicName,
                memo: memo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CheckupRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable: $$CheckupRecordsTableReferences
                                    ._childIdTable(db),
                                referencedColumn:
                                    $$CheckupRecordsTableReferences
                                        ._childIdTable(db)
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

typedef $$CheckupRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckupRecordsTable,
      CheckupRecordRow,
      $$CheckupRecordsTableFilterComposer,
      $$CheckupRecordsTableOrderingComposer,
      $$CheckupRecordsTableAnnotationComposer,
      $$CheckupRecordsTableCreateCompanionBuilder,
      $$CheckupRecordsTableUpdateCompanionBuilder,
      (CheckupRecordRow, $$CheckupRecordsTableReferences),
      CheckupRecordRow,
      PrefetchHooks Function({bool childId})
    >;
typedef $$ToothRecordsTableCreateCompanionBuilder =
    ToothRecordsCompanion Function({
      Value<int> id,
      required int childId,
      required int toothCode,
      required int status,
      Value<String?> note,
      required DateTime updatedAt,
    });
typedef $$ToothRecordsTableUpdateCompanionBuilder =
    ToothRecordsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<int> toothCode,
      Value<int> status,
      Value<String?> note,
      Value<DateTime> updatedAt,
    });

final class $$ToothRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ToothRecordsTable, ToothRecordRow> {
  $$ToothRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('tooth_records__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ToothRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ToothRecordsTable> {
  $$ToothRecordsTableFilterComposer({
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

  ColumnFilters<int> get toothCode => $composableBuilder(
    column: $table.toothCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToothRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ToothRecordsTable> {
  $$ToothRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get toothCode => $composableBuilder(
    column: $table.toothCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToothRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToothRecordsTable> {
  $$ToothRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get toothCode =>
      $composableBuilder(column: $table.toothCode, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToothRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ToothRecordsTable,
          ToothRecordRow,
          $$ToothRecordsTableFilterComposer,
          $$ToothRecordsTableOrderingComposer,
          $$ToothRecordsTableAnnotationComposer,
          $$ToothRecordsTableCreateCompanionBuilder,
          $$ToothRecordsTableUpdateCompanionBuilder,
          (ToothRecordRow, $$ToothRecordsTableReferences),
          ToothRecordRow,
          PrefetchHooks Function({bool childId})
        > {
  $$ToothRecordsTableTableManager(_$AppDatabase db, $ToothRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToothRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToothRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToothRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<int> toothCode = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ToothRecordsCompanion(
                id: id,
                childId: childId,
                toothCode: toothCode,
                status: status,
                note: note,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required int toothCode,
                required int status,
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
              }) => ToothRecordsCompanion.insert(
                id: id,
                childId: childId,
                toothCode: toothCode,
                status: status,
                note: note,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ToothRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable: $$ToothRecordsTableReferences
                                    ._childIdTable(db),
                                referencedColumn: $$ToothRecordsTableReferences
                                    ._childIdTable(db)
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

typedef $$ToothRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ToothRecordsTable,
      ToothRecordRow,
      $$ToothRecordsTableFilterComposer,
      $$ToothRecordsTableOrderingComposer,
      $$ToothRecordsTableAnnotationComposer,
      $$ToothRecordsTableCreateCompanionBuilder,
      $$ToothRecordsTableUpdateCompanionBuilder,
      (ToothRecordRow, $$ToothRecordsTableReferences),
      ToothRecordRow,
      PrefetchHooks Function({bool childId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChildrenTableTableManager get children =>
      $$ChildrenTableTableManager(_db, _db.children);
  $$PreventiveTasksTableTableManager get preventiveTasks =>
      $$PreventiveTasksTableTableManager(_db, _db.preventiveTasks);
  $$CheckupRecordsTableTableManager get checkupRecords =>
      $$CheckupRecordsTableTableManager(_db, _db.checkupRecords);
  $$ToothRecordsTableTableManager get toothRecords =>
      $$ToothRecordsTableTableManager(_db, _db.toothRecords);
}
