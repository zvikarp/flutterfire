// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;

/// Web implementation for [FirebaseDatabaseWeb]
/// delegates calls to firestore web plugin.
class FirebaseDatabaseWeb extends FirebaseDatabasePlatform {
  final database_interop.Database _webDatabase;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseDatabasePlatform.instance = FirebaseDatabaseWeb();
  }

  /// Builds an instance of [FirebaseFirestoreWeb] with an optional [FirebaseApp] instance.
  /// If [app] is null then the created instance will use the default [FirebaseApp].
  FirebaseDatabaseWeb({FirebaseApp /*?*/ app})
      : _webDatabase =
            database_interop.getDatabaseInstance(core_interop.app(app?.name)),
        super(appInstance: app);

  @override
  FirebaseDatabaseWeb delegateFor({/*required*/ FirebaseApp app}) {
    return FirebaseDatabaseWeb(app: app);
  }

  @override
  FirebaseDatabasePlatform setInitialValues() {
    return this;
  }

  @override
  DateTime getServerTime() {
    // TODO
  }

  @override
  Future<void> goOffline() async {
    _webDatabase.goOffline();
  }

  @override
  Future<void> goOnline() async {
    _webDatabase.goOnline();
  }

  @override
  ReferencePlatform ref(String /*?*/ ref) {
    // TODO
  }

  @override
  ReferencePlatform refFromURL(String /*!*/ ref) {
    // TODO
  }

  @override
  void useEmulator(String host, int port) {
    _webDatabase.useEmulator(host, port);
  }

  @override
  Future<void> setLoggingEnabled(bool enabled) {
    // TODO
  }

  @override
  Future<void> setPersistenceCacheSizeBytes(int bytes) async {
    // Not required/supported on web
    return;
  }
}
