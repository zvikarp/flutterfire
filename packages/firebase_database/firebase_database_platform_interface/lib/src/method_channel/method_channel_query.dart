// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_data_snapshot.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_database.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/exception.dart';

class MethodChannelQuery extends QueryPlatform {
  final FirebaseDatabasePlatform _database;
  final ReferencePlatform _ref;
  final List<dynamic> _modifiers;

  MethodChannelQuery(this._database, this._ref, this._modifiers,
      Map<String, dynamic> parameters)
      : super(_database, _ref, parameters);

  /// Creates a new instance of [MethodChannelQuery], however overrides
  /// any existing [parameters].
  ///
  /// This is in place to ensure that changes to a query don't mutate
  /// other queries.
  MethodChannelQuery _copyWithParameters(
      Map<String, dynamic> modifier, Map<String, dynamic> parameters) {
    return MethodChannelQuery(
      _database,
      _ref,
      _modifiers..add(modifier),
      Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(this.parameters)..addAll(parameters),
      ),
    );
  }

  @override
  Future<DataSnapshotPlatform> once() async {
    try {
      Map<String, dynamic> data = await MethodChannelFirebaseDatabase.channel
          .invokeMapMethod<String, dynamic>('Query#get', <String, dynamic>{
        'appName': _database.app.name,
        'modifiers': _modifiers
      });

      return MethodChannelDataSnapshot(_database, _ref.path, data);
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  QueryPlatform endAt(value, String /*?*/ key) {
    Map<String, dynamic> modifier = {
      'id': 'filter-endAt:$value:${key ?? ''}',
      'type': 'filter',
      'name': 'endAt',
      'value': value,
      'key': key,
    };

    return _copyWithParameters(modifier, <String, dynamic>{
      'endAt': modifier,
    });
  }

  @override
  QueryPlatform startAt(value, String /*?*/ key) {
    Map<String, dynamic> modifier = {
      'id': 'filter-startAt:$value:${key ?? ''}',
      'type': 'filter',
      'name': 'startAt',
      'value': value,
      'key': key,
    };

    return _copyWithParameters(modifier, <String, dynamic>{
      'startAt': modifier,
    });
  }

  @override
  QueryPlatform limitToFirst(int limit) {
    Map<String, dynamic> modifier = {
      'id': 'limit-limitToFirst:$limit',
      'type': 'limit',
      'name': 'limitToFirst',
      'value': limit,
      // 'viewFrom': 'left', // TODO: needed?
    };

    return _copyWithParameters(modifier, <String, dynamic>{
      'limit': modifier,
    });
  }

  @override
  QueryPlatform limitToLast(int limit) {
    Map<String, dynamic> modifier = {
      'id': 'limit-limitToLast:$limit',
      'type': 'limit',
      'name': 'limitToLast',
      'value': limit,
      // 'viewFrom': 'right', // TODO: needed?
    };

    return _copyWithParameters(modifier, <String, dynamic>{
      'limit': modifier,
    });
  }

  @override
  QueryPlatform orderByChild(String path) {
    Map<String, dynamic> modifier = {
      'id': 'order-orderByChild:$path',
      'type': 'orderBy',
      'name': 'orderByChild',
      'key': path,
    };

    return _copyWithParameters(modifier, <String, dynamic>{
      'orderBy': modifier,
    });
  }

  @override
  QueryPlatform orderByKey() {
    Map<String, dynamic> modifier = {
      'id': 'order-orderByKey',
      'type': 'orderBy',
      'name': 'orderByKey',
    };

    return _copyWithParameters(modifier, <String, dynamic>{
      'orderBy': modifier,
    });
  }

  @override
  QueryPlatform orderByPriority() {
    Map<String, dynamic> modifier = {
      'id': 'order-orderByPriority',
      'type': 'orderBy',
      'name': 'orderByPriority',
    };

    return _copyWithParameters(modifier, <String, dynamic>{
      'orderBy': modifier,
    });
  }

  @override
  QueryPlatform orderByValue() {
    Map<String, dynamic> modifier = {
      'id': 'order-orderByValue',
      'type': 'orderBy',
      'name': 'orderByValue',
    };

    return _copyWithParameters(modifier, <String, dynamic>{
      'orderBy': modifier,
    });
  }
}
