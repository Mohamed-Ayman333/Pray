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
    r'optionalPrayerCounter': PropertySchema(
      id: 0,
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
  writer.writeLong(offsets[0], object.optionalPrayerCounter);
}

UserState _userStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserState(
    optionalPrayerCounter: reader.readLongOrNull(offsets[0]) ?? 0,
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
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$UserStateToJson(UserState instance) => <String, dynamic>{
      'id': instance.id,
      'optionalPrayerCounter': instance.optionalPrayerCounter,
    };
