// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'package:firebase_database_platform_interface/src/internal/pointer.dart';

import 'platform_interface_reference.dart';

typedef bool /*?*/ DataSnapshotForEach(DataSnapshotPlatform /*!*/ snapshot);

class DataSnapshotPlatform extends PlatformInterface {
  /// The Database instance associated with this document reference
  final FirebaseDatabasePlatform _database;

  final Pointer _pointer;

  final Map<String, dynamic> _data;

  DataSnapshotPlatform(this._database, String path, this._data)
      : _pointer = Pointer(path),
        super(token: _token);

  static verifyExtends(DataSnapshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  static final Object _token = Object();

  String /*?*/ get key {
    return _pointer.key;
  }

  ReferencePlatform get ref {
    throw UnimplementedError("ref is not implemented");
  }

  dynamic get value => _data['data'];

  DataSnapshotPlatform /*?*/ child(String /*!*/ path) {
    throw UnimplementedError("child() is not implemented");
  }

  bool exists() {
    return _data['data'] != null;
  }

  // exportVal?

  bool /*!*/ forEach(DataSnapshotForEach action) {}

  dynamic getPriority() {
    return _data['priority'];
  }

  bool hasChild(String /*!*/ path) {
    if (!exists() || value is! Map) {
      return false;
    }

    return value[path] == null ? false : true;
  }

  bool hasChildren() {
    return numChildren() > 0;
  }

  int numChildren() {
    dynamic data = _data['data'];

    if (data is List) {
      return data.length;
    }

    if (data is Map) {
      return data.keys.length;
    }

    return 0;
  }
}
