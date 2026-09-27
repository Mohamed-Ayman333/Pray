// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsCollection on Isar {
  IsarCollection<Settings> get settings => this.collection();
}

const SettingsSchema = CollectionSchema(
  name: r'Settings',
  id: -8656046621518759136,
  properties: {
    r'autoIncrementOptionalPrayerCounterBy': PropertySchema(
      id: 0,
      name: r'autoIncrementOptionalPrayerCounterBy',
      type: IsarType.long,
    ),
    r'calculationMethod': PropertySchema(
      id: 1,
      name: r'calculationMethod',
      type: IsarType.byte,
      enumMap: _SettingscalculationMethodEnumValueMap,
    ),
    r'darkMode': PropertySchema(
      id: 2,
      name: r'darkMode',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 3,
      name: r'language',
      type: IsarType.byte,
      enumMap: _SettingslanguageEnumValueMap,
    ),
    r'latitude': PropertySchema(
      id: 4,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 5,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'madhab': PropertySchema(
      id: 6,
      name: r'madhab',
      type: IsarType.byte,
      enumMap: _SettingsmadhabEnumValueMap,
    ),
    r'notifications': PropertySchema(
      id: 7,
      name: r'notifications',
      type: IsarType.bool,
    ),
    r'repeatNotifications': PropertySchema(
      id: 8,
      name: r'repeatNotifications',
      type: IsarType.bool,
    ),
    r'showSunnahPrayers': PropertySchema(
      id: 9,
      name: r'showSunnahPrayers',
      type: IsarType.bool,
    ),
    r'stickyNotifications': PropertySchema(
      id: 10,
      name: r'stickyNotifications',
      type: IsarType.bool,
    )
  },
  estimateSize: _settingsEstimateSize,
  serialize: _settingsSerialize,
  deserialize: _settingsDeserialize,
  deserializeProp: _settingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsGetId,
  getLinks: _settingsGetLinks,
  attach: _settingsAttach,
  version: '3.1.0+1',
);

int _settingsEstimateSize(
  Settings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _settingsSerialize(
  Settings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.autoIncrementOptionalPrayerCounterBy);
  writer.writeByte(offsets[1], object.calculationMethod.index);
  writer.writeBool(offsets[2], object.darkMode);
  writer.writeByte(offsets[3], object.language.index);
  writer.writeDouble(offsets[4], object.latitude);
  writer.writeDouble(offsets[5], object.longitude);
  writer.writeByte(offsets[6], object.madhab.index);
  writer.writeBool(offsets[7], object.notifications);
  writer.writeBool(offsets[8], object.repeatNotifications);
  writer.writeBool(offsets[9], object.showSunnahPrayers);
  writer.writeBool(offsets[10], object.stickyNotifications);
}

Settings _settingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Settings(
    autoIncrementOptionalPrayerCounterBy:
        reader.readLongOrNull(offsets[0]) ?? 0,
    calculationMethod: _SettingscalculationMethodValueEnumMap[
            reader.readByteOrNull(offsets[1])] ??
        CalculationMethod.egyptian,
    darkMode: reader.readBoolOrNull(offsets[2]) ?? true,
    language:
        _SettingslanguageValueEnumMap[reader.readByteOrNull(offsets[3])] ??
            Language.en,
    latitude: reader.readDoubleOrNull(offsets[4]) ?? 30.0444,
    longitude: reader.readDoubleOrNull(offsets[5]) ?? 31.2357,
    madhab: _SettingsmadhabValueEnumMap[reader.readByteOrNull(offsets[6])] ??
        Madhab.shafi,
    notifications: reader.readBoolOrNull(offsets[7]) ?? false,
    repeatNotifications: reader.readBoolOrNull(offsets[8]) ?? false,
    showSunnahPrayers: reader.readBoolOrNull(offsets[9]) ?? false,
    stickyNotifications: reader.readBoolOrNull(offsets[10]) ?? false,
  );
  object.id = id;
  return object;
}

P _settingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (_SettingscalculationMethodValueEnumMap[
              reader.readByteOrNull(offset)] ??
          CalculationMethod.egyptian) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 3:
      return (_SettingslanguageValueEnumMap[reader.readByteOrNull(offset)] ??
          Language.en) as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 30.0444) as P;
    case 5:
      return (reader.readDoubleOrNull(offset) ?? 31.2357) as P;
    case 6:
      return (_SettingsmadhabValueEnumMap[reader.readByteOrNull(offset)] ??
          Madhab.shafi) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingscalculationMethodEnumValueMap = {
  'muslim_world_league': 0,
  'egyptian': 1,
  'karachi': 2,
  'umm_al_qura': 3,
  'dubai': 4,
  'moon_sighting_committee': 5,
  'north_america': 6,
  'kuwait': 7,
  'qatar': 8,
  'singapore': 9,
  'turkey': 10,
  'tehran': 11,
  'other': 12,
};
const _SettingscalculationMethodValueEnumMap = {
  0: CalculationMethod.muslim_world_league,
  1: CalculationMethod.egyptian,
  2: CalculationMethod.karachi,
  3: CalculationMethod.umm_al_qura,
  4: CalculationMethod.dubai,
  5: CalculationMethod.moon_sighting_committee,
  6: CalculationMethod.north_america,
  7: CalculationMethod.kuwait,
  8: CalculationMethod.qatar,
  9: CalculationMethod.singapore,
  10: CalculationMethod.turkey,
  11: CalculationMethod.tehran,
  12: CalculationMethod.other,
};
const _SettingslanguageEnumValueMap = {
  'ar': 0,
  'en': 1,
};
const _SettingslanguageValueEnumMap = {
  0: Language.ar,
  1: Language.en,
};
const _SettingsmadhabEnumValueMap = {
  'shafi': 0,
  'hanafi': 1,
};
const _SettingsmadhabValueEnumMap = {
  0: Madhab.shafi,
  1: Madhab.hanafi,
};

Id _settingsGetId(Settings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsGetLinks(Settings object) {
  return [];
}

void _settingsAttach(IsarCollection<dynamic> col, Id id, Settings object) {
  object.id = id;
}

extension SettingsQueryWhereSort on QueryBuilder<Settings, Settings, QWhere> {
  QueryBuilder<Settings, Settings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsQueryWhere on QueryBuilder<Settings, Settings, QWhereClause> {
  QueryBuilder<Settings, Settings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Settings, Settings, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Settings, Settings, QAfterWhereClause> idBetween(
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

extension SettingsQueryFilter
    on QueryBuilder<Settings, Settings, QFilterCondition> {
  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      autoIncrementOptionalPrayerCounterByEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autoIncrementOptionalPrayerCounterBy',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      autoIncrementOptionalPrayerCounterByGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autoIncrementOptionalPrayerCounterBy',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      autoIncrementOptionalPrayerCounterByLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autoIncrementOptionalPrayerCounterBy',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      autoIncrementOptionalPrayerCounterByBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autoIncrementOptionalPrayerCounterBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      calculationMethodEqualTo(CalculationMethod value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calculationMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      calculationMethodGreaterThan(
    CalculationMethod value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calculationMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      calculationMethodLessThan(
    CalculationMethod value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calculationMethod',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      calculationMethodBetween(
    CalculationMethod lower,
    CalculationMethod upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calculationMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> darkModeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'darkMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Settings, Settings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageEqualTo(
      Language value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageGreaterThan(
    Language value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageLessThan(
    Language value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> languageBetween(
    Language lower,
    Language upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> madhabEqualTo(
      Madhab value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'madhab',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> madhabGreaterThan(
    Madhab value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'madhab',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> madhabLessThan(
    Madhab value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'madhab',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> madhabBetween(
    Madhab lower,
    Madhab upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'madhab',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition> notificationsEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notifications',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      repeatNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatNotifications',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      showSunnahPrayersEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showSunnahPrayers',
        value: value,
      ));
    });
  }

  QueryBuilder<Settings, Settings, QAfterFilterCondition>
      stickyNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stickyNotifications',
        value: value,
      ));
    });
  }
}

extension SettingsQueryObject
    on QueryBuilder<Settings, Settings, QFilterCondition> {}

extension SettingsQueryLinks
    on QueryBuilder<Settings, Settings, QFilterCondition> {}

extension SettingsQuerySortBy on QueryBuilder<Settings, Settings, QSortBy> {
  QueryBuilder<Settings, Settings, QAfterSortBy>
      sortByAutoIncrementOptionalPrayerCounterBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoIncrementOptionalPrayerCounterBy', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      sortByAutoIncrementOptionalPrayerCounterByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
          r'autoIncrementOptionalPrayerCounterBy', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCalculationMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculationMethod', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByCalculationMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculationMethod', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkMode', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkMode', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByMadhab() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'madhab', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByMadhabDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'madhab', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifications', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifications', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByRepeatNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatNotifications', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      sortByRepeatNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatNotifications', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByShowSunnahPrayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSunnahPrayers', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByShowSunnahPrayersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSunnahPrayers', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> sortByStickyNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickyNotifications', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      sortByStickyNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickyNotifications', Sort.desc);
    });
  }
}

extension SettingsQuerySortThenBy
    on QueryBuilder<Settings, Settings, QSortThenBy> {
  QueryBuilder<Settings, Settings, QAfterSortBy>
      thenByAutoIncrementOptionalPrayerCounterBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoIncrementOptionalPrayerCounterBy', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      thenByAutoIncrementOptionalPrayerCounterByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
          r'autoIncrementOptionalPrayerCounterBy', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCalculationMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculationMethod', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByCalculationMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculationMethod', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkMode', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkMode', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByMadhab() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'madhab', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByMadhabDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'madhab', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifications', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifications', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByRepeatNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatNotifications', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      thenByRepeatNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatNotifications', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByShowSunnahPrayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSunnahPrayers', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByShowSunnahPrayersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showSunnahPrayers', Sort.desc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy> thenByStickyNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickyNotifications', Sort.asc);
    });
  }

  QueryBuilder<Settings, Settings, QAfterSortBy>
      thenByStickyNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stickyNotifications', Sort.desc);
    });
  }
}

extension SettingsQueryWhereDistinct
    on QueryBuilder<Settings, Settings, QDistinct> {
  QueryBuilder<Settings, Settings, QDistinct>
      distinctByAutoIncrementOptionalPrayerCounterBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoIncrementOptionalPrayerCounterBy');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByCalculationMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calculationMethod');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'darkMode');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByMadhab() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'madhab');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifications');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByRepeatNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatNotifications');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByShowSunnahPrayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showSunnahPrayers');
    });
  }

  QueryBuilder<Settings, Settings, QDistinct> distinctByStickyNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stickyNotifications');
    });
  }
}

extension SettingsQueryProperty
    on QueryBuilder<Settings, Settings, QQueryProperty> {
  QueryBuilder<Settings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Settings, int, QQueryOperations>
      autoIncrementOptionalPrayerCounterByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoIncrementOptionalPrayerCounterBy');
    });
  }

  QueryBuilder<Settings, CalculationMethod, QQueryOperations>
      calculationMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calculationMethod');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> darkModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'darkMode');
    });
  }

  QueryBuilder<Settings, Language, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<Settings, double, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<Settings, double, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<Settings, Madhab, QQueryOperations> madhabProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'madhab');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> notificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifications');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> repeatNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatNotifications');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> showSunnahPrayersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showSunnahPrayers');
    });
  }

  QueryBuilder<Settings, bool, QQueryOperations> stickyNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stickyNotifications');
    });
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      darkMode: json['darkMode'] as bool? ?? true,
      notifications: json['notifications'] as bool? ?? false,
      stickyNotifications: json['stickyNotifications'] as bool? ?? false,
      repeatNotifications: json['repeatNotifications'] as bool? ?? false,
      showSunnahPrayers: json['showSunnahPrayers'] as bool? ?? false,
      autoIncrementOptionalPrayerCounterBy:
          (json['autoIncrementOptionalPrayerCounterBy'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0444,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 31.2357,
      language: $enumDecodeNullable(_$LanguageEnumMap, json['language']) ??
          Language.en,
      calculationMethod: $enumDecodeNullable(
              _$CalculationMethodEnumMap, json['calculationMethod']) ??
          CalculationMethod.egyptian,
      madhab:
          $enumDecodeNullable(_$MadhabEnumMap, json['madhab']) ?? Madhab.shafi,
    )..id = (json['id'] as num).toInt();

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'id': instance.id,
      'darkMode': instance.darkMode,
      'notifications': instance.notifications,
      'stickyNotifications': instance.stickyNotifications,
      'repeatNotifications': instance.repeatNotifications,
      'showSunnahPrayers': instance.showSunnahPrayers,
      'autoIncrementOptionalPrayerCounterBy':
          instance.autoIncrementOptionalPrayerCounterBy,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'language': _$LanguageEnumMap[instance.language]!,
      'calculationMethod':
          _$CalculationMethodEnumMap[instance.calculationMethod]!,
      'madhab': _$MadhabEnumMap[instance.madhab]!,
    };

const _$LanguageEnumMap = {
  Language.ar: 'ar',
  Language.en: 'en',
};

const _$CalculationMethodEnumMap = {
  CalculationMethod.muslim_world_league: 'muslim_world_league',
  CalculationMethod.egyptian: 'egyptian',
  CalculationMethod.karachi: 'karachi',
  CalculationMethod.umm_al_qura: 'umm_al_qura',
  CalculationMethod.dubai: 'dubai',
  CalculationMethod.moon_sighting_committee: 'moon_sighting_committee',
  CalculationMethod.north_america: 'north_america',
  CalculationMethod.kuwait: 'kuwait',
  CalculationMethod.qatar: 'qatar',
  CalculationMethod.singapore: 'singapore',
  CalculationMethod.turkey: 'turkey',
  CalculationMethod.tehran: 'tehran',
  CalculationMethod.other: 'other',
};

const _$MadhabEnumMap = {
  Madhab.shafi: 'shafi',
  Madhab.hanafi: 'hanafi',
};
