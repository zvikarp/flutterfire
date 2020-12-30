// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

class Reference extends Query {
  final ReferencePlatform _delegate;

  Reference._(FirebaseDatabase database, this._delegate)
      : super._(database, _delegate);

  /// The last part of the Reference's path.
  ///
  /// For example, "ada" is the key for `https://<DATABASE_NAME>.firebaseio.com/users/ada`.
  ///
  /// The key of a root [Reference] is `null`.
  String /*?*/ get key {
    return _delegate.key;
  }

  Reference /*?*/ get parent {
    ReferencePlatform parentReferencePlatform = _delegate.parent;

    if (parentReferencePlatform == null) {
      return null;
    }

    return Reference._(database, parentReferencePlatform);
  }

  Reference get root {
    return Reference._(database, _delegate.root);
  }

  Reference child(String /*!*/ path) {
    return Reference._(database, _delegate.child(path));
  }

  OnDisconnect onDisconnect() {
    return OnDisconnect._(_delegate.onDisconnect());
  }

  Reference push() {
    return Reference._(database, _delegate.push());
  }

  Future<void> remove() {
    return _delegate.remove();
  }

  Future<void> set(dynamic value) {
    return _delegate.set(value);
  }

  Future<void> setPriority(dynamic priority) {
    _assertPriority(priority);
    return _delegate.setPriority(priority);
  }

  Future<void> setWithPriority(dynamic value, dynamic priority) {
    _assertPriority(priority);
    return _delegate.setWithPriority(value, priority);
  }

  Future<T> transaction<T>(TransactionHandler<T> handler,
      {Duration timeout = const Duration(seconds: 5),
      bool applyLocally = true}) {
    assert(timeout.inMilliseconds > 0);
    return _delegate.transaction(handler, timeout, applyLocally);
  }

  Future<void> update(dynamic value) {
    return _delegate.update(value);
  }
}
