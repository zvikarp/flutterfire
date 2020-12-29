// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

typedef bool /*?*/ DataSnapshotForEach(DataSnapshot /*!*/ snapshot);

class DataSnapshot {
  final FirebaseDatabase _database;

  final DataSnapshotPlatform _delegate;

  DataSnapshot._(this._database, this._delegate) {
    DataSnapshotPlatform.verifyExtends(_delegate);
  }

  String /*?*/ get key => _delegate.key;

  Reference get ref => Reference._(_database, _delegate.ref);

  dynamic /*?*/ get value => _delegate.value;

  DataSnapshot child(String /*!*/ path) {
    _assertChildPath(path);
    return DataSnapshot._(_database, _delegate.child(path));
  }

  bool /*?*/ exists() => _delegate.exists();

  bool forEach(DataSnapshotForEach action) {}

  bool hasChild(String /*!*/ path) {
    _assertChildPath(path);
    return _delegate.hasChild(path);
  }

  bool hasChildren() => _delegate.hasChildren();

  int numChildren() => _delegate.numChildren();
}

_assertChildPath(String value) {
  assert(value != null &&
      value.isNotEmpty &&
      !value.contains('.') &&
      !value.contains('#') &&
      !value.contains('\$') &&
      !value.contains('[') &&
      !value.contains(']'));
}
