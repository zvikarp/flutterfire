// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

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

  /// Ensures any delegate implementations extend this platform implementation.
  static verifyExtends(OnDisconnectPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  static final Object _token = Object();

  /// Cancels all previously queued [onDisconnect] [set] or [update] events for
  /// this location and all children.
  Future<void> cancel() {
    throw UnimplementedError("cancel() is not implemented");
  }

  /// Ensures the data at this location is deleted when the client is disconnected
  /// (due to closing the browser, navigating to a new page/screen, or network issues).
  Future<void> remove() {
    throw UnimplementedError("remove() is not implemented");
  }

  /// Ensures the data at this location is set to the specified value when the client
  /// is disconnected (due to closing the browser, navigating to a
  /// new page/screen, or network issues).
  ///
  /// [set] is especially useful for implementing "presence" systems,
  /// where a value should be changed or cleared when a user disconnects so that
  /// they appear "offline" to other users.
  Future<void> set(dynamic value) {
    throw UnimplementedError("set() is not implemented");
  }

  /// Ensures the data at this location is set to the specified value and priority
  /// when the client is disconnected (due to closing the browser, navigating
  /// to a new page/screen, or network issues).
  Future<void> setWithPriority(dynamic value, dynamic priority) {
    throw UnimplementedError("setWithPriority() is not implemented");
  }

  /// Writes multiple values at this location when the client is disconnected
  /// (due to closing the browser, navigating to a new page/screen, or network issues).
  ///
  /// The values argument contains multiple property-value pairs that will be written
  /// to the Database together. Each child property can either be a simple property
  /// (for example, "name") or a relative path (for example, "name/first") from
  /// the current location to the data to update.
  ///
  /// As opposed to the [set] method, [update] can be use to selectively update
  ///  only the referenced properties at the current location (instead of
  /// replacing all the child properties at the current location).
  Future<void> update(dynamic value) {
    throw UnimplementedError("update() is not implemented");
  }
}
