// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform_interface;
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/utils/encode_utility.dart';
import 'package:collection/collection.dart';

import 'aggregate_query_web.dart';
import 'internals.dart';
import 'interop/firestore.dart' as firestore_interop;
import 'utils/web_utils.dart';

/// Web implementation of Firestore [QueryPlatform].
class QueryWeb extends QueryPlatform {
  /// Builds an instance of [QueryWeb] delegating to a package:firebase [Query]
  /// to delegate queries to underlying firestore web plugin
  QueryWeb(
    FirebaseFirestorePlatform firestore,
    this._path,
    this._webQuery, {
    Map<String, dynamic>? parameters,
    this.isCollectionGroupQuery = false,
  }) : super(firestore, parameters);

  final firestore_interop.Query _webQuery;
  final String _path;

  /// Flags whether the current query is for a collection group.
  @override
  final bool isCollectionGroupQuery;

  @override
  bool operator ==(Object other) {
    return runtimeType == other.runtimeType &&
        other is QueryWeb &&
        other.firestore == firestore &&
        other._path == _path &&
        other.isCollectionGroupQuery == isCollectionGroupQuery &&
        const DeepCollectionEquality().equals(other.parameters, parameters);
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        firestore,
        _path,
        isCollectionGroupQuery,
        const DeepCollectionEquality().hash(parameters),
      );

  QueryWeb _copyWithParameters(Map<String, dynamic> parameters) {
    return QueryWeb(
      firestore,
      _path,
      _webQuery,
      isCollectionGroupQuery: isCollectionGroupQuery,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(this.parameters)..addAll(parameters),
      ),
    );
  }

  /// Builds a [web.Query] from given [parameters].
  firestore_interop.Query _buildWebQueryWithParameters() {
    firestore_interop.Query query = _webQuery;

    for (final List<dynamic> order in parameters['orderBy']) {
      query = query.orderBy(
          EncodeUtility.valueEncode(order[0]), order[1] ? 'desc' : 'asc');
    }

    if (parameters['startAt'] != null) {
      query = query.startAt(
          fieldValues: EncodeUtility.valueEncode(parameters['startAt']));
    }

    if (parameters['startAfter'] != null) {
      query = query.startAfter(
          fieldValues: EncodeUtility.valueEncode(parameters['startAfter']));
    }

    if (parameters['endAt'] != null) {
      query = query.endAt(
          fieldValues: EncodeUtility.valueEncode(parameters['endAt']));
    }

    if (parameters['endBefore'] != null) {
      query = query.endBefore(
          fieldValues: EncodeUtility.valueEncode(parameters['endBefore']));
    }

    if (parameters['limit'] != null) {
      query = query.limit(parameters['limit']);
    }

    if (parameters['limitToLast'] != null) {
      query = query.limitToLast(parameters['limitToLast']);
    }

    if (parameters['filters'] != null) {
      final Map<String, Object?> filter = parameters['filters']!;
      query = query.filterWith(filter);
    }

    for (final List<dynamic> condition in parameters['where']) {
      dynamic fieldPath = EncodeUtility.valueEncode(condition[0]);
      String opStr = condition[1];
      dynamic value = EncodeUtility.valueEncode(condition[2]);

      query = query.where(fieldPath, opStr, value);
    }

    return query;
  }

  @override
  QueryPlatform endAtDocument(List<dynamic> orders, List<dynamic> values) {
    return _copyWithParameters(<String, dynamic>{
      'orderBy': orders,
      'endAt': values,
      'endBefore': null,
    });
  }

  @override
  QueryPlatform endAt(Iterable<dynamic> fields) {
    return _copyWithParameters(<String, dynamic>{
      'endAt': fields,
      'endBefore': null,
    });
  }

  @override
  QueryPlatform endBeforeDocument(
      Iterable<dynamic> orders, Iterable<dynamic> values) {
    return _copyWithParameters(<String, dynamic>{
      'orderBy': orders,
      'endAt': null,
      'endBefore': values,
    });
  }

  @override
  QueryPlatform endBefore(Iterable<dynamic> fields) {
    return _copyWithParameters(<String, dynamic>{
      'endAt': null,
      'endBefore': fields,
    });
  }

  @override
  Future<QuerySnapshotPlatform> get([GetOptions options = const GetOptions()]) {
    return convertWebExceptions(() async {
      return convertWebQuerySnapshot(
        firestore,
        await _buildWebQueryWithParameters().get(convertGetOptions(options)),
        options.serverTimestampBehavior,
      );
    });
  }

  @override
  QueryPlatform limit(int limit) {
    return _copyWithParameters(<String, dynamic>{
      'limit': limit,
      'limitToLast': null,
    });
  }

  @override
  QueryPlatform limitToLast(int limit) {
    return _copyWithParameters(<String, dynamic>{
      'limit': null,
      'limitToLast': limit,
    });
  }

  @override
  Stream<QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    Stream<firestore_interop.QuerySnapshot> querySnapshots =
        _buildWebQueryWithParameters().onSnapshot(
      includeMetadataChanges: includeMetadataChanges,
      source: source,
      hashCode: hashCode,
    );

    return convertWebExceptions(
      () => querySnapshots.map((webQuerySnapshot) {
        return convertWebQuerySnapshot(
          firestore,
          webQuerySnapshot,
          ServerTimestampBehavior.none,
        );
      }),
    );
  }

  @override
  QueryPlatform orderBy(Iterable<List<dynamic>> orders) {
    return _copyWithParameters(<String, dynamic>{'orderBy': orders});
  }

  @override
  QueryPlatform startAfterDocument(List<dynamic> orders, List<dynamic> values) {
    return _copyWithParameters(<String, dynamic>{
      'orderBy': orders,
      'startAt': null,
      'startAfter': values,
    });
  }

  @override
  QueryPlatform startAfter(Iterable<dynamic> fields) {
    return _copyWithParameters(<String, dynamic>{
      'startAt': null,
      'startAfter': fields,
    });
  }

  @override
  QueryPlatform startAtDocument(
      Iterable<dynamic> orders, Iterable<dynamic> values) {
    return _copyWithParameters(<String, dynamic>{
      'orderBy': orders,
      'startAt': values,
      'startAfter': null,
    });
  }

  @override
  QueryPlatform startAt(Iterable<dynamic> fields) {
    return _copyWithParameters(<String, dynamic>{
      'startAt': fields,
      'startAfter': null,
    });
  }

  @override
  QueryPlatform where(Iterable<List<dynamic>> conditions) {
    return _copyWithParameters(<String, dynamic>{
      'where': conditions,
    });
  }

  @override
  QueryPlatform whereFilter(FilterPlatformInterface filter) {
    return _copyWithParameters(<String, dynamic>{
      'filters': filter.toJson(),
    });
  }

  @override
  AggregateQueryPlatform count() {
    return AggregateQueryWeb(
      this,
      _buildWebQueryWithParameters(),
      [
        AggregateQuery(
          type: AggregateType.count,
        )
      ],
    );
  }

  @override
  AggregateQueryPlatform aggregate(
    AggregateField aggregateField1, [
    AggregateField? aggregateField2,
    AggregateField? aggregateField3,
    AggregateField? aggregateField4,
    AggregateField? aggregateField5,
    AggregateField? aggregateField6,
    AggregateField? aggregateField7,
    AggregateField? aggregateField8,
    AggregateField? aggregateField9,
    AggregateField? aggregateField10,
    AggregateField? aggregateField11,
    AggregateField? aggregateField12,
    AggregateField? aggregateField13,
    AggregateField? aggregateField14,
    AggregateField? aggregateField15,
    AggregateField? aggregateField16,
    AggregateField? aggregateField17,
    AggregateField? aggregateField18,
    AggregateField? aggregateField19,
    AggregateField? aggregateField20,
    AggregateField? aggregateField21,
    AggregateField? aggregateField22,
    AggregateField? aggregateField23,
    AggregateField? aggregateField24,
    AggregateField? aggregateField25,
    AggregateField? aggregateField26,
    AggregateField? aggregateField27,
    AggregateField? aggregateField28,
    AggregateField? aggregateField29,
    AggregateField? aggregateField30,
  ]) {
    final fields = [
      aggregateField1,
      aggregateField2,
      aggregateField3,
      aggregateField4,
      aggregateField5,
      aggregateField6,
      aggregateField7,
      aggregateField8,
      aggregateField9,
      aggregateField10,
      aggregateField11,
      aggregateField12,
      aggregateField13,
      aggregateField14,
      aggregateField15,
      aggregateField16,
      aggregateField17,
      aggregateField18,
      aggregateField19,
      aggregateField20,
      aggregateField21,
      aggregateField22,
      aggregateField23,
      aggregateField24,
      aggregateField25,
      aggregateField26,
      aggregateField27,
      aggregateField28,
      aggregateField29,
      aggregateField30,
    ].whereType<AggregateField>();
    return AggregateQueryWeb(
      this,
      _buildWebQueryWithParameters(),
      fields.map((e) {
        if (e is platform_interface.count) {
          return AggregateQuery(
            type: AggregateType.count,
          );
        } else if (e is platform_interface.sum) {
          return AggregateQuery(
            type: AggregateType.sum,
            field: e.field,
          );
        } else if (e is platform_interface.average) {
          return AggregateQuery(
            type: AggregateType.average,
            field: e.field,
          );
        } else {
          throw UnsupportedError(
            'Unsupported aggregate field type ${e.runtimeType}',
          );
        }
      }).toList(),
    );
  }

  @override
  AggregateQueryPlatform sum(String field) {
    return AggregateQueryWeb(
      this,
      _buildWebQueryWithParameters(),
      [
        AggregateQuery(
          type: AggregateType.sum,
          field: field,
        )
      ],
    );
  }

  @override
  AggregateQueryPlatform average(String field) {
    return AggregateQueryWeb(
      this,
      _buildWebQueryWithParameters(),
      [
        AggregateQuery(
          type: AggregateType.average,
          field: field,
        )
      ],
    );
  }
}
