// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// A [Query] sorts and filters the data at a Database location so only a subset
/// of the child data is included. This can be used to order a collection of
/// data by some attribute (for example, height of dinosaurs) as well as to
/// restrict a large list of items (for example, chat messages) down to a number
/// suitable for synchronizing to the client. Queries are created by chaining
/// together one or more of the filter methods defined here.
class Query {
  final FirebaseDatabase _database;

  final QueryPlatform _delegate;

  Query._(this._database, this._delegate) {
    QueryPlatform.verifyExtends(_delegate);
  }

  /// Accesses the current query parameters on the underlying implementation.
  Map<String, dynamic> get _parameters {
    return _delegate.parameters;
  }

  /// Returns whether the current instance has an [endAt] modifier.
  bool _hasEndAt() {
    return _parameters['endAt'] != null;
  }

  /// Returns whether the current instance has an [startAt] modifier.
  bool _hasStartAt() {
    return _parameters['startAt'] != null;
  }

  /// Returns whether the currrent instance has an [limitTo*] modifier.
  bool _hasLimit() {
    return _parameters['limit'] != null;
  }

  /// Returns whether the currrent instance has an [orderBy*] modifier.
  bool _hasOrderBy() {
    return _parameters['orderBy'] != null;
  }

  /// Validates parameters on the delegate implementation of this [Query] instance.
  ///
  /// Once validated, a new [Query] instance with the validated parameters is returned.
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

    return Query._(_database, modified);
  }

  /// Returns a [Reference] to the Query's location.
  Reference get ref {
    return Reference._(_database, _delegate.ref);
  }

  /// Creates a [Query] with the specified ending point.
  ///
  /// Using [startAt], [endAt] and [equalTo] allows you to choose arbitrary
  /// starting and ending points for your queries.
  ///
  /// The ending point is inclusive, so children with exactly the specified value
  /// will be included in the query. The optional key argument can be used to further
  /// limit the range of the query. If it is specified, then children that have
  /// exactly the specified value must also have a key name less than or equal
  /// to the specified key.
  Query endAt(dynamic /*?*/ value, String /*?*/ key) {
    _assertQueryValue(value);

    if (_hasEndAt()) {
      throw StateError(
          "Ending point was already set (by another call to endAt or equalTo)");
    }

    return _validate(_delegate.endAt(value, key));
  }

  /// Creates a [Query] that includes children that match the specified value.
  ///
  /// Using [startAt], [endAt], and [equalTo] allows us to choose arbitrary starting
  /// and ending points for our queries.
  ///
  /// The optional key argument can be used to further limit the range of the query.
  /// If it is specified, then children that have exactly the specified value must
  /// also have exactly the specified key as their key name. This can be used to
  /// filter result sets with many matches for the same value.
  ///
  /// Note; the underlying delegate implementation does not exist, since calling
  /// [equalTo] is the same as setting starting and ending points with the same
  /// value.
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

  /// Generates a new [Query] limited to the first specific number of children.
  ///
  /// The [limitToFirst] method is used to set a maximum number of children to be
  /// synced for a given callback.
  Query limitToFirst(int limit) {
    _assertLimitValue(limit);

    if (_hasLimit()) {
      throw StateError(
          "Limit was already set (by another call to limitToFirst, or limitToLast).");
    }

    return _validate(_delegate.limitToFirst(limit));
  }

  /// Generates a new [Query] limited to the last specific number of children.
  ///
  /// The [limitToLast] method is used to set a maximum number of children to be
  /// synced for a given callback.
  Query limitToLast(int limit) {
    _assertLimitValue(limit);

    if (_hasLimit()) {
      throw StateError(
          "Limit was already set (by another call to limitToFirst, or limitToLast).");
    }

    return _validate(_delegate.limitToLast(limit));
  }

  /// Listens for exactly one event of the specified event type, and then stops listening.
  Future<DataSnapshot> once() async {
    return DataSnapshot._(_database, await _delegate.once());
  }

  /// This [Stream] will be triggered once for each initial child at this location,
  /// and it will be triggered again every time a new child is added.
  ///
  /// The DataSnapshot passed into the callback will reflect the data for the
  /// relevant child. For ordering purposes, it is passed a second argument which
  /// is a string containing the key of the previous sibling child by sort order,
  /// or `null` if it is the first child.
  Stream<DataSnapshot> get onChildAdded {
    throw UnimplementedError("onChildAdded is not implemented");
  }

  /// This [Stream] will be triggered once every time a child is removed.
  /// The [DataSnapshot] passed into the callback will be the old data for the
  /// child that was removed.
  ///
  /// A child will get removed when either:
  ///   - a client explicitly calls [remove] on that child or one of its ancestors
  ///   - a client calls [set] with `null` on that child or one of its ancestors
  ///   - that child has all of its children removed
  ///   - there is a query in effect which now filters out the child (because
  ///     it's sort order changed or the max limit was hit)
  Stream<DataSnapshot> get onChildRemoved {
    throw UnimplementedError("onChildRemoved is not implemented");
  }

  /// This [Stream] will be triggered when the data stored in a child (or any of its descendants) changes.
  ///
  /// Note that a single event may represent multiple changes to the child.
  /// The [DataSnapshot] passed to the callback will contain the new child contents.
  /// For ordering purposes, the callback is also passed a second argument which is
  /// a string containing the key of the previous sibling child by sort order,
  /// or `null` if it is the first child.
  Stream<DataSnapshot> get onChildChanged {
    throw UnimplementedError("onChildChanged is not implemented");
  }

  /// This [Stream] will be triggered when a child's sort order changes such that
  /// its position relative to its siblings changes.
  ///
  /// The [DataSnapshot] passed to the callback will be for the data of the child
  /// that has moved. It is also passed a second argument which is a string containing
  /// the key of the previous sibling child by sort order, or `null` if it is the
  /// first child.
  Stream<DataSnapshot> get onChildMoved {
    throw UnimplementedError("onChildMoved is not implemented");
  }

  /// This [Stream] will trigger once with the initial data stored at this location,
  /// and then trigger again each time the data changes.
  ///
  /// The [DataSnapshot] passed to the callback will be for the location of the [Reference].
  /// It won't trigger until the entire contents has been synchronized. If
  /// the location has no data, it will be triggered with an empty [DataSnapshot].
  Stream<DataSnapshot> get onValue {
    throw UnimplementedError("onValue is not implemented");
  }

  /// Generates a new [Query] object ordered by the specified child key.
  ///
  /// Queries can only order by one key at a time. Calling [orderByChild]
  /// multiple times on the same query is an error.
  ///
  /// Firebase queries allow you to order your data by any child key on the fly.
  /// However, if you know in advance what your indexes will be, you can define
  /// them via the `.indexOn` rule in your Security Rules for better performance.
  Query orderByChild(String path) {
    _assertOrderPath(path);

    if (_hasOrderBy()) {
      throw StateError("You can not combine multiple orderBy* calls.");
    }

    return _validate(_delegate.orderByChild(path));
  }

  /// Generates a new [Query] object ordered by key.
  ///
  ///Sorts the results of a query by their (ascending) key values
  Query orderByKey() {
    if (_hasOrderBy()) {
      throw StateError("You can not combine multiple orderBy* calls.");
    }

    return _validate(_delegate.orderByKey());
  }

  /// Generates a new [Query] object ordered by priority.
  Query orderByPriority() {
    if (_hasOrderBy()) {
      throw StateError("You can not combine multiple orderBy* calls.");
    }

    return _validate(_delegate.orderByPriority());
  }

  /// Generates a new [Query] object ordered by value.
  ///
  /// If the children of a query are all scalar values ([String], [num], or [bool]),
  /// you can order the results by their (ascending) values.
  Query orderByValue() {
    if (_hasOrderBy()) {
      throw StateError("You can not combine multiple orderBy* calls.");
    }

    return _validate(_delegate.orderByValue());
  }

  /// Creates a [Query] with the specified starting point.
  ///
  /// Using [startAt], [endAt] and [equalTo] allows you to choose arbitrary
  /// starting and ending points for your queries.
  ///
  /// The starting point is inclusive, so children with exactly the specified value
  /// will be included in the query. The optional key argument can be used to further
  /// limit the range of the query. If it is specified, then children that have
  /// exactly the specified value must also have a key name less than or equal
  /// to the specified key.
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
