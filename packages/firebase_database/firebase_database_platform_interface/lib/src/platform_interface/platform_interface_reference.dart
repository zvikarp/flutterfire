// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*melos-nullsafety-remove-start*/
import 'dart:async';
/*melos-nullsafety-remove-end*/

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'package:firebase_database_platform_interface/src/internal/pointer.dart';
import 'package:firebase_database_platform_interface/src/internal/push_id_generator.dart';

/// A [ReferencePlatform] can be used for querying nodes on the database and mutating
/// nodes.
///
/// Note: QueryPlatform extends PlatformInterface already.
abstract class ReferencePlatform extends QueryPlatform {
  static final Object _token = Object();

  /// Create instance of [DocumentReferencePlatform]
  ReferencePlatform(
    this.database,
    String /*?*/ path,
  )   : _pointer = Pointer(path),
        super(database, database.ref(path), {});

  /// The Database instance associated with this document reference
  final FirebaseDatabasePlatform database;

  final Pointer _pointer;

  /// The full path to the Reference's path on the database.
  String /*!*/ get path {
    return _pointer.path;
  }

  /// The last part of the Reference's path.
  ///
  /// For example, "ada" is the key for `https://<DATABASE_NAME>.firebaseio.com/users/ada`.
  ///
  /// The key of a root [Reference] is `null`.
  String /*?*/ get key {
    return _pointer.key;
  }

  ReferencePlatform /*?*/ get parent {
    String /*?*/ parentPath = _pointer.parentPath();

    if (parentPath == null) {
      return null;
    }

    return database.ref(parentPath);
  }

  ReferencePlatform get root {
    return database.ref("/");
  }

  ReferencePlatform child(String /*!*/ path) {
    return database.ref(_pointer.child(path).path);
  }

  OnDisconnectPlatform onDisconnect() {
    throw UnimplementedError("onDisconnect() is not implemented");
  }

  ReferencePlatform push() {
    final String key = PushIdGenerator.generatePushChildName();
    return database.ref(_pointer.child(key).path);
  }

  Future<void> remove() {
    throw UnimplementedError("remove() is not implemented");
  }

  Future<void> set(dynamic value) {
    throw UnimplementedError("set() is not implemented");
  }

  Future<void> setPriority(dynamic priority) {
    throw UnimplementedError("setPriority() is not implemented");
  }

  Future<void> setWithPriority(dynamic value, dynamic priority) {
    throw UnimplementedError("setWithPriority() is not implemented");
  }

  Future<T> transaction<T>(
      TransactionHandler<T> handler, Duration timeout, bool applyLocally) {
    throw UnimplementedError("transaction() is not implemented");
  }

  Future<void> update(dynamic value) {
    throw UnimplementedError("set() is not implemented");
  }
}
