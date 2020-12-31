// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_reference.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

/// The entry point for accessing Database.
///
/// You can get an instance by calling [FirebaseDatabase.instance].
class MethodChannelFirebaseDatabase extends FirebaseDatabasePlatform {
  bool _initialized = false;

  int /*?*/ _serverTimeOffset;

  /// Create an instance of [MethodChannelFirebaseDatabase].
  MethodChannelFirebaseDatabase({FirebaseApp /*!*/ app})
      : super(appInstance: app) {
    if (_initialized) return;
    _syncServerTimeOffset();
    _initialized = true;
  }

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_database');

  /// Returns an [EventChannel] for a given identifer (which was created)
  /// on the native platform.
  static EventChannel getQueryEventStream(String identifier) {
    return EventChannel('plugins.flutter.io/firebase_database/$identifier');
  }

  _syncServerTimeOffset() {
    const EventChannel _syncServerTimeOffsetStream = EventChannel(
        'plugins.flutter.io/firebase_database#syncServerTimeOffset');

    if (_serverTimeOffset == null) {
      _syncServerTimeOffsetStream.receiveBroadcastStream().listen((data) {
        _serverTimeOffset = data as int;
      });
    }
  }

  /// Gets a [FirebaseFirestorePlatform] with specific arguments such as a different
  /// [FirebaseApp].
  @override
  FirebaseDatabasePlatform delegateFor({/*required*/ FirebaseApp app}) {
    return MethodChannelFirebaseDatabase(app: app);
  }

  @override
  FirebaseDatabasePlatform setInitialValues() {
    return this;
  }

  @override
  DateTime getServerTime() {
    return DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch + _serverTimeOffset ?? 0);
  }

  @override
  Future<void> goOffline() async {
    try {
      await channel.invokeMethod<void>(
          'Database#goOffline', <String, dynamic>{'appName': app.name});
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> goOnline() async {
    try {
      await channel.invokeMethod<void>(
          'Database#goOnline', <String, dynamic>{'appName': app.name});
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  ReferencePlatform ref(String /*?*/ ref) {
    return MethodChannelReference(this, ref);
  }
}
