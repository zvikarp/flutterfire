// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_data_snapshot.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_database.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_reference.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/exception.dart';
import 'package:flutter/services.dart';

/// The [MethodChannel] delegate implementation for [QueryPlatform].
class MethodChannelQuery extends QueryPlatform {
  final FirebaseDatabasePlatform _database;
  final String _ref;
  final List<dynamic> _modifiers;

  /// Constructs a new [MethodChannelQuery] instance.
  MethodChannelQuery(this._database, this._ref, this._modifiers,
      Map<String, dynamic> parameters)
      : super(_database, parameters);

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

  String _getValueType(dynamic value) {
    if (value is String) return 'string';
    if (value is num) return 'number';
    if (value is bool) return 'boolean';
    return 'null';
  }

  @override
  ReferencePlatform get ref {
    return MethodChannelReference(database, _ref);
  }

  /// Creates a new unique [Stream] & [EventStream] then listens to all events.
  ///
  /// Events from the [EventSteam] are converted into a [DataSnapshotPlatform] instance
  /// and then posted to the [Stream].
  ///
  /// It's important to remember that native SDKs listen to all "child" events
  /// at once, so if you only require specific child events (e.g. onChildAdded)
  /// then ensure the [Stream] is filtered on a specific event type.
  Stream<DataSnapshotPlatform> _getQueryStream(String event) {
    StreamController<DataSnapshotPlatform> controller;
    StreamSubscription<dynamic> dataSnapshotStream;

    controller =
        StreamController<DataSnapshotPlatform>.broadcast(onListen: () async {
      // Create a new native EventChannel and return the unique identifier
      final String identifier = await MethodChannelFirebaseDatabase.channel
          .invokeMethod<String>('Query#$event', <String, dynamic>{
        'appName': _database.app.name,
        'path': _ref,
        'modifiers': _modifiers
      });

      // Get a new Dart EventChannel for the unique identifier
      EventChannel uniqueEventChannel =
          MethodChannelFirebaseDatabase.getQueryEventStream(identifier);

      dataSnapshotStream =
          uniqueEventChannel.receiveBroadcastStream().listen((event) {
        // Create a new DataSnapshot and add it to the stream
        controller.add(MethodChannelDataSnapshot(
          _database,
          _ref,
          event['event'],
          Map<String, dynamic>.from(event['snapshot']),
        ));
      }, onError: (e, s) {
        controller.addError(convertPlatformException(e, s));
      });
    }, onCancel: () {
      dataSnapshotStream?.cancel();
    });

    return controller.stream;
  }

  @override
  Future<DataSnapshotPlatform> once() async {
    return _getQueryStream('once').first;
  }

  @override
  Stream<DataSnapshotPlatform> get onChildEvent {
    return _getQueryStream('onChild');
  }

  @override
  Stream<DataSnapshotPlatform> get onChildAdded {
    return _getQueryStream('onChild').where((DataSnapshotPlatform snapshot) {
      return snapshot.event == DataSnapshotEvent.onChildAdded;
    });
  }

  @override
  Stream<DataSnapshotPlatform> get onChildChanged {
    return _getQueryStream('onChild').where((DataSnapshotPlatform snapshot) {
      return snapshot.event == DataSnapshotEvent.onChildChanged;
    });
  }

  @override
  Stream<DataSnapshotPlatform> get onChildMoved {
    return _getQueryStream('onChild').where((DataSnapshotPlatform snapshot) {
      return snapshot.event == DataSnapshotEvent.onChildMoved;
    });
  }

  @override
  Stream<DataSnapshotPlatform> get onChildRemoved {
    return _getQueryStream('onChild').where((DataSnapshotPlatform snapshot) {
      return snapshot.event == DataSnapshotEvent.onChildRemoved;
    });
  }

  @override
  Stream<DataSnapshotPlatform> get onValue {
    return _getQueryStream('onValue');
  }

  @override
  QueryPlatform endAt(value, String /*?*/ key) {
    Map<String, dynamic> modifier = {
      'id': 'filter-endAt:$value:${key ?? ''}',
      'type': 'filter',
      'name': 'endAt',
      'value': value,
      'valueType': _getValueType(value),
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
      'valueType': _getValueType(value),
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
