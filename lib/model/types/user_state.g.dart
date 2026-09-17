// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserStateCollection on Isar {
  IsarCollection<UserState> get userStates => this.collection();
}

const UserStateSchema = CollectionSchema(
  name: r'UserState',
  id: -3052082333501167064,
  properties: {
    r'hasPromptedBatteryExemption': PropertySchema(
      id: 0,
      name: r'hasPromptedBatteryExemption',
      type: IsarType.bool,
    ),
    r'lastAutoIncrementDate': PropertySchema(
      id: 1,
      name: r'lastAutoIncrementDate',
      type: IsarType.dateTime,
    ),
    r'optionalPrayerCounter': PropertySchema(
      id: 2,
      name: r'optionalPrayerCounter',
      type: IsarType.long,
    )
  },
  estimateSize: _userStateEstimateSize,
  serialize: _userStateSerialize,
  deserialize: _userStateDeserialize,
  deserializeProp: _userStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userStateGetId,
  getLinks: _userStateGetLinks,
  attach: _userStateAttach,
  version: '3.1.0+1',
);

int _userStateEstimateSize(
  UserState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userStateSerialize(
  UserState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hasPromptedBatteryExemption);
  writer.writeDateTime(offsets[1], object.lastAutoIncrementDate);
  writer.writeLong(offsets[2], object.optionalPrayerCounter);
}

UserState _userStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserState(
    hasPromptedBatteryExemption: reader.readBoolOrNull(offsets[0]) ?? false,
    lastAutoIncrementDate: reader.readDateTimeOrNull(offsets[1]),
    optionalPrayerCounter: reader.readLongOrNull(offsets[2]) ?? 0,
  );
  object.id = id;
  return object;
}

P _userStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userStateGetId(UserState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userStateGetLinks(UserState object) {
  return [];
}

void _userStateAttach(IsarCollection<dynamic> col, Id id, UserState object) {
  object.id = id;
}

extension UserStateQueryWhereSort
    on QueryBuilder<UserState, UserState, QWhere> {
  QueryBuilder<UserState, UserState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserStateQueryWhere
    on QueryBuilder<UserState, UserState, QWhereClause> {
  QueryBuilder<UserState, UserState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserState, UserState, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserState, UserState, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserState, UserState, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserStateQueryFilter
    on QueryBuilder<UserState, UserState, QFilterCondition> {
  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      hasPromptedBatteryExemptionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasPromptedBatteryExemption',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      lastAutoIncrementDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAutoIncrementDate',
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      lastAutoIncrementDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAutoIncrementDate',
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      lastAutoIncrementDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAutoIncrementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      lastAutoIncrementDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAutoIncrementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      lastAutoIncrementDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAutoIncrementDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      lastAutoIncrementDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAutoIncrementDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      optionalPrayerCounterEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'optionalPrayerCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      optionalPrayerCounterGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'optionalPrayerCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      optionalPrayerCounterLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'optionalPrayerCounter',
        value: value,
      ));
    });
  }

  QueryBuilder<UserState, UserState, QAfterFilterCondition>
      optionalPrayerCounterBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'optionalPrayerCounter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserStateQueryObject
    on QueryBuilder<UserState, UserState, QFilterCondition> {}

extension UserStateQueryLinks
    on QueryBuilder<UserState, UserState, QFilterCondition> {}

extension UserStateQuerySortBy on QueryBuilder<UserState, UserState, QSortBy> {
  QueryBuilder<UserState, UserState, QAfterSortBy>
      sortByHasPromptedBatteryExemption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPromptedBatteryExemption', Sort.asc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      sortByHasPromptedBatteryExemptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPromptedBatteryExemption', Sort.desc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      sortByLastAutoIncrementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoIncrementDate', Sort.asc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      sortByLastAutoIncrementDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoIncrementDate', Sort.desc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      sortByOptionalPrayerCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'optionalPrayerCounter', Sort.asc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      sortByOptionalPrayerCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'optionalPrayerCounter', Sort.desc);
    });
  }
}

extension UserStateQuerySortThenBy
    on QueryBuilder<UserState, UserState, QSortThenBy> {
  QueryBuilder<UserState, UserState, QAfterSortBy>
      thenByHasPromptedBatteryExemption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPromptedBatteryExemption', Sort.asc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      thenByHasPromptedBatteryExemptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPromptedBatteryExemption', Sort.desc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      thenByLastAutoIncrementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoIncrementDate', Sort.asc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      thenByLastAutoIncrementDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoIncrementDate', Sort.desc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      thenByOptionalPrayerCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'optionalPrayerCounter', Sort.asc);
    });
  }

  QueryBuilder<UserState, UserState, QAfterSortBy>
      thenByOptionalPrayerCounterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'optionalPrayerCounter', Sort.desc);
    });
  }
}

extension UserStateQueryWhereDistinct
    on QueryBuilder<UserState, UserState, QDistinct> {
  QueryBuilder<UserState, UserState, QDistinct>
      distinctByHasPromptedBatteryExemption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPromptedBatteryExemption');
    });
  }

  QueryBuilder<UserState, UserState, QDistinct>
      distinctByLastAutoIncrementDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAutoIncrementDate');
    });
  }

  QueryBuilder<UserState, UserState, QDistinct>
      distinctByOptionalPrayerCounter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'optionalPrayerCounter');
    });
  }
}

extension UserStateQueryProperty
    on QueryBuilder<UserState, UserState, QQueryProperty> {
  QueryBuilder<UserState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserState, bool, QQueryOperations>
      hasPromptedBatteryExemptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPromptedBatteryExemption');
    });
  }

  QueryBuilder<UserState, DateTime?, QQueryOperations>
      lastAutoIncrementDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAutoIncrementDate');
    });
  }

  QueryBuilder<UserState, int, QQueryOperations>
      optionalPrayerCounterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'optionalPrayerCounter');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserState _$UserStateFromJson(Map<String, dynamic> json) => UserState(
      optionalPrayerCounter:
          (json['optionalPrayerCounter'] as num?)?.toInt() ?? 0,
      hasPromptedBatteryExemption:
          json['hasPromptedBatteryExemption'] as bool? ?? false,
      lastAutoIncrementDate: json['lastAutoIncrementDate'] == null
          ? null
          : DateTime.parse(json['lastAutoIncrementDate'] as String),
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$UserStateToJson(UserState instance) => <String, dynamic>{
      'id': instance.id,
      'optionalPrayerCounter': instance.optionalPrayerCounter,
      'hasPromptedBatteryExemption': instance.hasPromptedBatteryExemption,
      'lastAutoIncrementDate':
          instance.lastAutoIncrementDate?.toIso8601String(),
    };
