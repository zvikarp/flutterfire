// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

class Query {
  final FirebaseDatabase database;

  final QueryPlatform _delegate;

  Query._(this.database, this._delegate) {
    QueryPlatform.verifyExtends(_delegate);
  }

  Map<String, dynamic> get parameters {
    return _delegate.parameters;
  }

  bool _hasEndAt() {
    return parameters['endAt'] != null;
  }

  bool _hasStartAt() {
    return parameters['startAt'] != null;
  }

  bool _hasLimit() {
    return parameters['limit'] != null;
  }

  bool _hasOrderBy() {
    return parameters['orderBy'] != null;
  }

  Query _validate(QueryPlatform modified) {
    Map<String, dynamic> params = modified.parameters;

    if (params['orderBy'] && params['orderBy']['name'] == 'orderByKey') {
      if ((params['startAt'] && params['startAt']['key'] != null) ||
          (params['endAt'] && params['endAt']['key'] != null)) {
        throw StateError(
            "When ordering by key, you may only pass a value argument to startAt(), endAt(), or equalTo().");
      }
    }

    if (params['orderBy'] && params['orderBy']['name'] == 'orderByKey') {
      if ((params['startAt'] && params['startAt']['value'] is! String) ||
          (params['endAt'] && params['endAt']['value'] is! String)) {
        throw StateError(
            "When ordering by key, the value of startAt(), endAt(), or equalTo() must be a string.");
      }
    }

    if (params['orderBy'] && params['orderBy']['name'] == 'orderByPriority') {
      if ((params['startAt'] &&
              !_isValidPriority(params['startAt']['value'])) ||
          (params['endAt'] && !_isValidPriority(params['endAt']['value']))) {
        throw StateError(
            "When ordering by priority, the first value of startAt(), endAt(), or equalTo() must be a valid priority value ([null], [int], or [String]).");
      }
    }

    return Query._(database, modified);
  }

  Query endAt(dynamic /*?*/ value, String /*?*/ key) {
    _assertQueryValue(value);

    if (_hasEndAt()) {
      throw StateError(
          "Ending point was already set (by another call to endAt or equalTo)");
    }

    return _validate(_delegate.endAt(value, key));
  }

  Query equalTo(dynamic /*?*/ value, String /*?*/ key) {
    _assertQueryValue(value);

    if (_hasStartAt()) {
      throw StateError(
          "Starting point was already set (by another call to startAt or equalTo).");
    }

    if (_hasEndAt()) {
      throw StateError(
          "Ending point was already set (by another call to endAt or equalTo).");
    }

    return _validate(_delegate.startAt(value, key).endAt(value, key));
  }

  Query limitToFirst(int limit) {
    _assertLimitValue(limit);

    if (_hasLimit()) {
      throw StateError(
          "Limit was already set (by another call to limitToFirst, or limitToLast).");
    }

    return _validate(_delegate.limitToFirst(limit));
  }

  Query limitToLast(int limit) {
    _assertLimitValue(limit);

    if (_hasLimit()) {
      throw StateError(
          "Limit was already set (by another call to limitToFirst, or limitToLast).");
    }

    return _validate(_delegate.limitToLast(limit));
  }

  Future<DataSnapshot> once() async {
    return DataSnapshot._(database, await _delegate.once());
  }

  Stream<DataSnapshot> get onChildAdded {
    throw UnimplementedError("onChildAdded is not implemented");
  }

  Stream<DataSnapshot> get onChildRemoved {
    throw UnimplementedError("onChildRemoved is not implemented");
  }

  Stream<DataSnapshot> get onChildChanged {
    throw UnimplementedError("onChildChanged is not implemented");
  }

  Stream<DataSnapshot> get onChildMoved {
    throw UnimplementedError("onChildMoved is not implemented");
  }

  Stream<DataSnapshot> get onValue {
    throw UnimplementedError("onValue is not implemented");
  }

  Query orderByChild(String path) {
    _assertOrderPath(path);

    if (_hasOrderBy()) {
      throw StateError("You can not combine multiple orderBy* calls.");
    }

    return _validate(_delegate.orderByChild(path));
  }

  Query orderByKey() {
    if (_hasOrderBy()) {
      throw StateError("You can not combine multiple orderBy* calls.");
    }

    return _validate(_delegate.orderByKey());
  }

  Query orderByPriority() {
    if (_hasOrderBy()) {
      throw StateError("You can not combine multiple orderBy* calls.");
    }

    return _validate(_delegate.orderByPriority());
  }

  Query orderByValue() {
    if (_hasOrderBy()) {
      throw StateError("You can not combine multiple orderBy* calls.");
    }

    return _validate(_delegate.orderByValue());
  }

  Query startAt(dynamic /*?*/ value, String /*?*/ key) {
    _assertQueryValue(value);

    if (_hasStartAt()) {
      throw StateError(
          "Starting point was already set (by another call to startAt or equalTo)");
    }

    return _validate(_delegate.startAt(value, key));
  }
}

_assertQueryValue(dynamic value) {
  assert(value is String || value is num || value is bool || value == null,
      "Query value must be one of [String], [num], [bool] or [null]");
}

_assertLimitValue(int value) {
  assert(value > 0, "Limit value must be an integer greather than zero");
}

_assertOrderPath(String path) {
  assert(path != null);
  assert(path.isNotEmpty,
      "An order by path can not be empty. Use [orderByValue] instead.");
}
