// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_database.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/exception.dart';

/// The [MethodChannel] delegate implementation for [OnDisconnectPlatform].
class MethodChannelOnDisconnect extends OnDisconnectPlatform {
  final FirebaseDatabasePlatform _database;
  final ReferencePlatform _ref;

  /// Constructs a new [MethodChannelOnDisconnect] instance.
  MethodChannelOnDisconnect(this._database, this._ref) : super();

  @override
  Future<void> cancel() async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('OnDisconnect#cancel', {
        'appName': _database.app.name,
        'path': _ref.path,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> remove() async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('OnDisconnect#remove', {
        'appName': _database.app.name,
        'path': _ref.path,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> set(dynamic value) async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('OnDisconnect#set', {
        'appName': _database.app.name,
        'path': _ref.path,
        'value': value,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(dynamic value, dynamic priority) async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('OnDisconnect#setWithPriority', {
        'appName': _database.app.name,
        'path': _ref.path,
        'value': value,
        'priority': priority,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> update(dynamic value) async {
    try {
      await MethodChannelFirebaseDatabase.channel
          .invokeMethod('OnDisconnect#update', {
        'appName': _database.app.name,
        'path': _ref.path,
        'value': value,
      });
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }
}
