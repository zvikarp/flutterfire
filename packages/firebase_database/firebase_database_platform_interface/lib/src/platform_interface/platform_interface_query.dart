// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*melos-nullsafety-remove-start*/
import 'dart:async';
/*melos-nullsafety-remove-end*/

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import '../../firebase_database_platform_interface.dart';

Map<String, dynamic> _initialParameters = Map<String, dynamic>.unmodifiable({
  'endAt': null,
  'startAt': null,
  'limit': null,
  'orderBy': null,
});

/// Represents a query over the data at a particular location.
abstract class QueryPlatform extends PlatformInterface {
  /// The [FirebaseDatabasePlatform] interface for this current query.
  final FirebaseDatabasePlatform database;

  /// The [ReferencePlatform] interface for this current query.
  final ReferencePlatform ref;

  /// Stores the instances query modifier filters.
  Map<String, dynamic> parameters;

  /// Create a [QueryPlatform] instance
  QueryPlatform(this.database, this.ref, Map<String, dynamic> /*?*/ parameters)
      : this.parameters = parameters ?? _initialParameters,
        super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [QueryPlatform].
  ///
  /// This is used by the app-facing [Reference] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(ReferencePlatform instance) {
    if (instance is! ReferencePlatform) {
      PlatformInterface.verifyToken(instance, _token);
    }
  }

  QueryPlatform endAt(dynamic /*?*/ value, String /*?*/ key) {
    throw UnimplementedError("endAt() is not implemented");
  }

  // isEqual - override class

  QueryPlatform limitToFirst(int limit) {
    throw UnimplementedError("limitToFirst() is not implemented");
  }

  QueryPlatform limitToLast(int limit) {
    throw UnimplementedError("limitToLast() is not implemented");
  }

  Future<DataSnapshotPlatform> once() async {
    throw UnimplementedError("once() is not implemented");
  }

  Stream<DataSnapshotPlatform> get onChildAdded {
    throw UnimplementedError("onChildAdded is not implemented");
  }

  Stream<DataSnapshotPlatform> get onChildRemoved {
    throw UnimplementedError("onChildRemoved is not implemented");
  }

  Stream<DataSnapshotPlatform> get onChildChanged {
    throw UnimplementedError("onChildChanged is not implemented");
  }

  Stream<DataSnapshotPlatform> get onChildMoved {
    throw UnimplementedError("onChildMoved is not implemented");
  }

  Stream<DataSnapshotPlatform> get onValue {
    throw UnimplementedError("onValue is not implemented");
  }

  QueryPlatform orderByChild(String path) {
    throw UnimplementedError("orderByChild() is not implemented");
  }

  QueryPlatform orderByKey() {
    throw UnimplementedError("orderByKey() is not implemented");
  }

  QueryPlatform orderByPriority() {
    throw UnimplementedError("orderByPriority() is not implemented");
  }

  QueryPlatform orderByValue() {
    throw UnimplementedError("orderByValue() is not implemented");
  }

  QueryPlatform startAt(dynamic /*?*/ value, String /*?*/ key) {
    throw UnimplementedError("startAt() is not implemented");
  }

  // toJSON?

  // toString - class override

}
