// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// The entry point for accessing [FirebaseDatabase].
///
/// To get an instance, call [FirebaseDatabase.instance]. To use a non-default
/// [FirebaseApp] instance, use [FirebaseDatabase.instanceFor] instead.
class FirebaseDatabase extends FirebasePluginPlatform {
  // Cached and lazily loaded instance of [DatabasePlatform] to avoid
  // creating a [MethodChannelDatabase] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseDatabasePlatform _delegatePackingProperty;

  FirebaseDatabasePlatform /*!*/ get _delegate {
    if (_delegatePackingProperty == null) {
      _delegatePackingProperty = FirebaseDatabasePlatform.instanceFor(app: app);
    }

    return _delegatePackingProperty;
  }

  /// The [FirebaseApp] for this current [FirebaseDatabase] instance.
  final FirebaseApp app;

  FirebaseDatabase._({/*required*/ this.app})
      : super(app.name, 'plugins.flutter.io/firebase_database');

  static final Map<String, FirebaseDatabase> _cachedInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseDatabase get instance {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
    );
  }

  /// Returns an instance using a specified [FirebaseApp].
  static FirebaseDatabase /*!*/ instanceFor({FirebaseApp app}) {
    assert(app != null);
    if (_cachedInstances.containsKey(app.name)) {
      return _cachedInstances[app.name] /*!*/;
    }

    FirebaseDatabase newInstance = FirebaseDatabase._(app: app);
    _cachedInstances[app.name] = newInstance;

    return newInstance;
  }

  /// Returns the current Firebase Database server time as a [DateTime].
  DateTime getServerTime() => _delegate.getServerTime();

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
    return _delegate.goOffline();
  }

  /// Reconnects to the server and synchronizes the offline Database state with the server state.
  ///
  /// This method should be used after disabling the active connection with [goOffline].
  /// Once reconnected, the client will transmit the proper data and fire the
  /// appropriate events so that your client "catches up" automatically.
  Future<void> goOnline() {
    return _delegate.goOnline();
  }

  /// Returns a [Reference] representing the location in the Database corresponding
  /// to the provided path. If no path is provided, the [Reference] will point
  /// to the root of the Database.
  Reference ref(String /*?*/ ref) {
    return Reference._(this, _delegate.ref(ref));
  }

  /// Returns a [Reference] representing the location in the Database corresponding to the provided Firebase URL.
  ///
  /// An exception is thrown if the URL is not a valid Firebase Database URL or
  /// it has a different domain than the current Database instance.
  ///
  /// Note that all query parameters ([orderBy], [limitToLast], etc.) are ignored and
  /// are not applied to the returned Reference.
  Reference refFromURL(String /*!*/ url) {
    assert(url != null);
    return Reference._(this, _delegate.refFromURL(url));
  }

  /// Modify this instance to communicate with the Realtime Database emulator.
  ///
  /// Note: This method must be called before performing any other operation.
  void useEmulator(String /*!*/ host, int /*!*/ port) {
    assert(host != null);
    assert(port != null);
    _delegate.useEmulator(host, port);
  }

  /// Sets the logging level for the Firebase Database SDKs.
  ///
  /// By default, only warnings and errors are logged natively. Setting this to
  /// `true` will log all database events.
  Future<void> setLoggingEnabled(bool /*!*/ enabled) =>
      _delegate.setLoggingEnabled(enabled ?? false);

  /// By default Firebase Database will use up to 10MB of disk space to cache data.
  ///
  /// If the cache grows beyond this size, Firebase Database will start removing
  /// data that hasn't been recently used. If you find that your application
  /// caches too little or too much data, call this method to change the cache size.
  /// This method must be called before creating your first Database reference
  /// and only needs to be called once per application.
  Future<void> setPersistenceCacheSizeBytes(int /*!*/ bytes) {
    assert(bytes > 1048576,
        "The minimum number of bytes for cache is 1mb (1048576 bytes)");
    assert(bytes < 104857600,
        "The maximum number of bytes for cache is 100mb (104857600 bytes)");
    return _delegate.setPersistenceCacheSizeBytes(bytes);
  }
}
