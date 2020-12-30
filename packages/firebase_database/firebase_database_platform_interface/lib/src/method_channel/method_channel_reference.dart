// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/internal/pointer.dart';
import 'package:firebase_database_platform_interface/src/internal/push_id_generator.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_database.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_on_disconnect.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_query.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/exception.dart';

/// The [MethodChannel] delegate implementation for [ReferencePlatform].
class MethodChannelReference extends MethodChannelQuery
    implements ReferencePlatform {
  final Pointer _pointer;

  /// Create a [MethodChannelCollectionReference] instance.
  MethodChannelReference(FirebaseDatabasePlatform database, String ref)
      : _pointer = Pointer(ref),
        super(database, ref, [], {});

  @override
  String get path => _pointer.path;

  @override
  String get key => _pointer.key;

  @override
  ReferencePlatform /*?*/ get parent {
    String parentPath = _pointer.parentPath();

    if (parentPath == null) {
      return null;
    }

    return MethodChannelReference(database, parentPath);
  }

  @override
  ReferencePlatform /*!*/ get root {
    return MethodChannelReference(database, "/");
  }

  @override
  ReferencePlatform child(String /*!*/ path) {
    return MethodChannelReference(database, _pointer.child(path).path);
  }

  @override
  OnDisconnectPlatform onDisconnect() {
    return MethodChannelOnDisconnect(database, this);
  }

  @override
  ReferencePlatform push() {
    String id = PushIdGenerator.generatePushChildName();
    return MethodChannelReference(database, _pointer.child(id).path);
  }

  @override
  Future<void> remove() async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('Reference#remove', {
        'appName': database.app.name,
        'path': _pointer.path,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> set(value) async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('Reference#set', {
        'appName': database.app.name,
        'path': _pointer.path,
        'value': value,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setPriority(priority) async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('Reference#setPriority', {
        'appName': database.app.name,
        'path': _pointer.path,
        'priority': priority,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(value, priority) async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('Reference#setWithPriority', {
        'appName': database.app.name,
        'path': _pointer.path,
        'value': value,
        'priority': priority,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<DataSnapshotPlatform> transaction<T>(TransactionHandler<T> handler,
      Duration timeout, bool applyLocally) async {}

  @override
  Future<void> update(value) async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('Reference#update', {
        'appName': database.app.name,
        'path': _pointer.path,
        'value': value,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }
}
