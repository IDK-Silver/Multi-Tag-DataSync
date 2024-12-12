// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBasicConfigCollection on Isar {
  IsarCollection<BasicConfig> get basicConfigs => this.collection();
}

const BasicConfigSchema = CollectionSchema(
  name: r'BasicConfig',
  id: 4314864014279567711,
  properties: {
    r'apiURL': PropertySchema(
      id: 0,
      name: r'apiURL',
      type: IsarType.string,
    ),
    r'isLogin': PropertySchema(
      id: 1,
      name: r'isLogin',
      type: IsarType.bool,
    ),
    r'realStoragePath': PropertySchema(
      id: 2,
      name: r'realStoragePath',
      type: IsarType.string,
    ),
    r'token': PropertySchema(
      id: 3,
      name: r'token',
      type: IsarType.string,
    )
  },
  estimateSize: _basicConfigEstimateSize,
  serialize: _basicConfigSerialize,
  deserialize: _basicConfigDeserialize,
  deserializeProp: _basicConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _basicConfigGetId,
  getLinks: _basicConfigGetLinks,
  attach: _basicConfigAttach,
  version: '3.1.0+1',
);

int _basicConfigEstimateSize(
  BasicConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.apiURL;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.realStoragePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.token;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _basicConfigSerialize(
  BasicConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.apiURL);
  writer.writeBool(offsets[1], object.isLogin);
  writer.writeString(offsets[2], object.realStoragePath);
  writer.writeString(offsets[3], object.token);
}

BasicConfig _basicConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BasicConfig();
  object.apiURL = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.isLogin = reader.readBoolOrNull(offsets[1]);
  object.realStoragePath = reader.readStringOrNull(offsets[2]);
  object.token = reader.readStringOrNull(offsets[3]);
  return object;
}

P _basicConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _basicConfigGetId(BasicConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _basicConfigGetLinks(BasicConfig object) {
  return [];
}

void _basicConfigAttach(
    IsarCollection<dynamic> col, Id id, BasicConfig object) {
  object.id = id;
}

extension BasicConfigQueryWhereSort
    on QueryBuilder<BasicConfig, BasicConfig, QWhere> {
  QueryBuilder<BasicConfig, BasicConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BasicConfigQueryWhere
    on QueryBuilder<BasicConfig, BasicConfig, QWhereClause> {
  QueryBuilder<BasicConfig, BasicConfig, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<BasicConfig, BasicConfig, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterWhereClause> idBetween(
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

extension BasicConfigQueryFilter
    on QueryBuilder<BasicConfig, BasicConfig, QFilterCondition> {
  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> apiURLIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'apiURL',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      apiURLIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'apiURL',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> apiURLEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      apiURLGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apiURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> apiURLLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apiURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> apiURLBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apiURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      apiURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apiURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> apiURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apiURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> apiURLContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apiURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> apiURLMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apiURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      apiURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiURL',
        value: '',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      apiURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apiURL',
        value: '',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      isLoginIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isLogin',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      isLoginIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isLogin',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> isLoginEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLogin',
        value: value,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'realStoragePath',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'realStoragePath',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realStoragePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'realStoragePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'realStoragePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'realStoragePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'realStoragePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'realStoragePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'realStoragePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'realStoragePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'realStoragePath',
        value: '',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      realStoragePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'realStoragePath',
        value: '',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'token',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      tokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'token',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      tokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'token',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'token',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition> tokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterFilterCondition>
      tokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'token',
        value: '',
      ));
    });
  }
}

extension BasicConfigQueryObject
    on QueryBuilder<BasicConfig, BasicConfig, QFilterCondition> {}

extension BasicConfigQueryLinks
    on QueryBuilder<BasicConfig, BasicConfig, QFilterCondition> {}

extension BasicConfigQuerySortBy
    on QueryBuilder<BasicConfig, BasicConfig, QSortBy> {
  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> sortByApiURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiURL', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> sortByApiURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiURL', Sort.desc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> sortByIsLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLogin', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> sortByIsLoginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLogin', Sort.desc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> sortByRealStoragePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realStoragePath', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy>
      sortByRealStoragePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realStoragePath', Sort.desc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }
}

extension BasicConfigQuerySortThenBy
    on QueryBuilder<BasicConfig, BasicConfig, QSortThenBy> {
  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenByApiURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiURL', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenByApiURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiURL', Sort.desc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenByIsLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLogin', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenByIsLoginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLogin', Sort.desc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenByRealStoragePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realStoragePath', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy>
      thenByRealStoragePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'realStoragePath', Sort.desc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QAfterSortBy> thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }
}

extension BasicConfigQueryWhereDistinct
    on QueryBuilder<BasicConfig, BasicConfig, QDistinct> {
  QueryBuilder<BasicConfig, BasicConfig, QDistinct> distinctByApiURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apiURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QDistinct> distinctByIsLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLogin');
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QDistinct> distinctByRealStoragePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'realStoragePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BasicConfig, BasicConfig, QDistinct> distinctByToken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token', caseSensitive: caseSensitive);
    });
  }
}

extension BasicConfigQueryProperty
    on QueryBuilder<BasicConfig, BasicConfig, QQueryProperty> {
  QueryBuilder<BasicConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BasicConfig, String?, QQueryOperations> apiURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apiURL');
    });
  }

  QueryBuilder<BasicConfig, bool?, QQueryOperations> isLoginProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLogin');
    });
  }

  QueryBuilder<BasicConfig, String?, QQueryOperations>
      realStoragePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'realStoragePath');
    });
  }

  QueryBuilder<BasicConfig, String?, QQueryOperations> tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token');
    });
  }
}
