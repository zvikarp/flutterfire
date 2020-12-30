// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*melos-nullsafety-remove-start*/
import 'dart:async';
/*melos-nullsafety-remove-end*/

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_database.dart';

/// The interface that implementations of `firebase_database` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_database` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseDatabasePlatform] methods.
abstract class FirebaseDatabasePlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp /*?*/ appInstance;

  /// Create an instance using [app]
  FirebaseDatabasePlatform({this.appInstance}) : super(token: _token);

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp /*!*/ get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance;
  }

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory FirebaseDatabasePlatform.instanceFor(
      {FirebaseApp app, Map<dynamic, dynamic> pluginConstants}) {
    return FirebaseDatabasePlatform.instance
        .delegateFor(app: app)
        .setInitialValues();
  }

  /// The current default [FirebaseAuthPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseAuth]
  /// if no other implementation was provided.
  static FirebaseDatabasePlatform get instance {
    if (_instance == null) {
      _instance = MethodChannelFirebaseDatabase(app: Firebase.app());
    }

    return _instance;
  }

  static FirebaseDatabasePlatform _instance;

  /// Sets the [FirebaseDatabasePlatform.instance]
  static set instance(FirebaseDatabasePlatform instance) {
    assert(instance != null);
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseDatabasePlatform /*!*/ delegateFor({FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be available
  /// before the instance has initialized to prevent any unnecessary async
  /// calls.
  @protected
  FirebaseDatabasePlatform setInitialValues() {
    throw UnimplementedError('setInitialValues() is not implemented');
  }

  /// Returns the current Firebase Database server time as a [DateTime].
  DateTime getServerTime() {
    throw UnimplementedError('getServerTime() is not implemented');
  }

  /// Disconnects from the server (all Database operations will be completed offline).
  ///
  /// The client automatically maintains a persistent connection to the Database server,
  /// which will remain active indefinitely and reconnect when disconnected. However,
  /// the goOffline() and goOnline() methods may be used to control the client
  /// connection in cases where a persistent connection is undesirable.
  ///
  /// While offline, the client will no longer receive data updates from the Database.
  /// However, all Database operations performed locally will continue to immediately
  /// fire events, allowing your application to continue behaving normally.
  /// Additionally, each operation performed locally will automatically be queued
  /// and retried upon reconnection to the Database server.
  ///
  /// To reconnect to the Database and begin receiving remote events, see [goOnline].
  Future<void> goOffline() {
    throw UnimplementedError("goOffline() is not implemented");
  }

  /// Reconnects to the server and synchronizes the offline Database state with the server state.
  ///
  /// This method should be used after disabling the active connection with [goOffline].
  /// Once reconnected, the client will transmit the proper data and fire the
  /// appropriate events so that your client "catches up" automatically.
  Future<void> goOnline() {
    throw UnimplementedError("goOnline() is not implemented");
  }

  /// Returns a [Reference] representing the location in the Database corresponding
  /// to the provided path. If no path is provided, the [Reference] will point
  /// to the root of the Database.
  ReferencePlatform /*!*/ ref(String /*?*/ ref) {
    throw UnimplementedError("ref() is not implemented");
  }

  /// Returns a [Reference] representing the location in the Database corresponding to the provided Firebase URL.
  ///
  /// An exception is thrown if the URL is not a valid Firebase Database URL or
  /// it has a different domain than the current Database instance.
  ///
  /// Note that all query parameters ([orderBy], [limitToLast], etc.) are ignored and
  /// are not applied to the returned Reference.
  ReferencePlatform /*!*/ refFromURL(String /*!*/ url) {
    throw UnimplementedError("refFromURL() is not implemented");
  }

  /// Modify this instance to communicate with the Realtime Database emulator.
  ///
  /// Note: This method must be called before performing any other operation.
  void useEmulator(String host, int port) {
    throw UnimplementedError("useEmulator() is not implemented");
  }

  /// Sets the logging level for the Firebase Database SDKs.
  ///
  /// By default, only warnings and errors are logged natively. Setting this to
  /// `true` will log all database events.
  Future<void> setLoggingEnabled(bool /*!*/ enabled) {
    throw UnimplementedError("setLoggingEnabled() is not implemented");
  }

  /// By default Firebase Database will use up to 10MB of disk space to cache data.
  /// 
  /// If the cache grows beyond this size, Firebase Database will start removing
  /// data that hasn't been recently used. If you find that your application 
  /// caches too little or too much data, call this method to change the cache size.
  /// This method must be called before creating your first Database reference
  /// and only needs to be called once per application.
  Future<void> setPersistenceCacheSizeBytes(int /*!*/ bytes) {
    throw UnimplementedError(
        "setPersistenceCacheSizeBytes() is not implemented");
  }
}
