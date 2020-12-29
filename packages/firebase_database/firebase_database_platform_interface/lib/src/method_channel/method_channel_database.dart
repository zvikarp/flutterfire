// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*melos-nullsafety-remove-start*/
import 'dart:async';
/*melos-nullsafety-remove-end*/

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

/// The entry point for accessing Database.
///
/// You can get an instance by calling [FirebaseDatabase.instance].
class MethodChannelFirebaseDatabase extends FirebaseDatabasePlatform {
  /// Create an instance of [MethodChannelFirebaseDatabase].
  MethodChannelFirebaseDatabase({FirebaseApp /*!*/ app})
      : super(appInstance: app);

  /// Gets a [FirebaseFirestorePlatform] with specific arguments such as a different
  /// [FirebaseApp].
  @override
  FirebaseDatabasePlatform delegateFor({/*required*/ FirebaseApp app}) {
    return MethodChannelFirebaseDatabase(app: app);
  }

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_database');

  @override
  FirebaseDatabasePlatform setInitialValues() {
    return this;
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
}
