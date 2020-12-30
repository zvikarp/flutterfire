// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

class OnDisconnect {
  final OnDisconnectPlatform _delegate;

  OnDisconnect._(this._delegate) {
    OnDisconnectPlatform.verifyExtends(_delegate);
  }

  Future<void> cancel() {
    return _delegate.cancel();
  }

  Future<void> remove() {
    return _delegate.remove();
  }

  Future<void> set(dynamic value) {
    return _delegate.set(value);
  }

  Future<void> setWithPriority(dynamic value, dynamic priority) {
    _assertPriority(priority);
    return _delegate.setWithPriority(value, priority);
  }

  Future<void> update(dynamic value) {
    return _delegate.update(value);
  }
}
