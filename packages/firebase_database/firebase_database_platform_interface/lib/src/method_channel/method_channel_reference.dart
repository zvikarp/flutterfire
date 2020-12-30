// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_query.dart';

class MethodChannelReference extends MethodChannelQuery
    implements ReferencePlatform {
  /// Create a [MethodChannelCollectionReference] instance.
  MethodChannelReference(
      FirebaseDatabasePlatform database, ReferencePlatform ref)
      : super(database, ref, [], {});

  @override
  ReferencePlatform child(String path) {}

  @override
  String get key => throw UnimplementedError();

  @override
  OnDisconnectPlatform onDisconnect() {}

  @override
  ReferencePlatform get parent => throw UnimplementedError();

  @override
  String get path => throw UnimplementedError();

  @override
  ReferencePlatform push() {
    // TODO: implement push
    throw UnimplementedError();
  }

  @override
  Future<void> remove() {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  // TODO: implement root
  ReferencePlatform get root => throw UnimplementedError();

  @override
  Future<void> set(value) {
    // TODO: implement set
    throw UnimplementedError();
  }

  @override
  Future<void> setPriority(priority) {
    // TODO: implement setPriority
    throw UnimplementedError();
  }

  @override
  Future<void> setWithPriority(value, priority) {
    // TODO: implement setWithPriority
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(TransactionHandler<T> handler, Duration timeout, bool applyLocally) {}

  @override
  Future<void> update(value) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
