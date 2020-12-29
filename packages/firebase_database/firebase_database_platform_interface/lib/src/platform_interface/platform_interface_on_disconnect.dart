// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

/// The [OnDisconnect] class allows you to write or clear data when your client
/// disconnects from the Database server. These updates occur whether your client
/// disconnects cleanly or not, so you can rely on them to clean up data even if
/// a connection is dropped or a client crashes.
class OnDisconnectPlatform extends PlatformInterface {
  /// The [FirebaseDatabasePlatform] interface for this current query.
  final FirebaseDatabasePlatform _database;

  /// The [ReferencePlatform] interface for this current query.
  final ReferencePlatform _ref;

  /// Create a [OnDisconnectPlatform] instance.
  OnDisconnectPlatform(this._database, this._ref) : super(token: _token);

  static final Object _token = Object();

  Future<void> cancel() {
    throw UnimplementedError("cancel() is not implemented");
  }

  Future<void> remove() {
    throw UnimplementedError("remove() is not implemented");
  }

  Future<void> set(dynamic value) {
    throw UnimplementedError("set() is not implemented");
  }

  Future<void> setWithPriority(dynamic value, dynamic priority) {
    throw UnimplementedError("setWithPriority() is not implemented");
  }

  Future<void> update(dynamic value) {
    throw UnimplementedError("update() is not implemented");
  }
}
