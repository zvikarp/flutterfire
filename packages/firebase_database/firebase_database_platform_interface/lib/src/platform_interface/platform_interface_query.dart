// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import '../../firebase_database_platform_interface.dart';

Map<String, dynamic> _initialParameters = Map<String, dynamic>.unmodifiable({
  'endAt': null,
  'startAt': null,
  'limit': null,
  'orderBy': null,
});

/// The platform interface for a [Query] implementation.
///
/// A [Query] sorts and filters the data at a Database location so only a subset
/// of the child data is included. This can be used to order a collection of
/// data by some attribute (for example, height of dinosaurs) as well as to
/// restrict a large list of items (for example, chat messages) down to a number
/// suitable for synchronizing to the client. Queries are created by chaining
/// together one or more of the filter methods defined here.
abstract class QueryPlatform extends PlatformInterface {
  /// The [FirebaseDatabasePlatform] interface for this current query.
  final FirebaseDatabasePlatform database;

  /// Stores the instances query modifier filters.
  Map<String, dynamic> parameters;

  /// Create a [QueryPlatform] instance
  QueryPlatform(this.database, Map<String, dynamic> /*?*/ parameters)
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

  /// Returns a [ReferencePlatform] to the Query's location.
  ReferencePlatform get ref {
    throw UnimplementedError("ref is not implemented");
  }

  /// Creates a [QueryPlatform] with the specified ending point.
  ///
  /// Using [startAt], [endAt] and [equalTo] allows you to choose arbitrary
  /// starting and ending points for your queries.
  ///
  /// The ending point is inclusive, so children with exactly the specified value
  /// will be included in the query. The optional key argument can be used to further
  /// limit the range of the query. If it is specified, then children that have
  /// exactly the specified value must also have a key name less than or equal
  /// to the specified key.
  QueryPlatform endAt(dynamic /*?*/ value, String /*?*/ key) {
    throw UnimplementedError("endAt() is not implemented");
  }

  // isEqual - override class

  /// Generates a new [QueryPlatform] limited to the first specific number of children.
  ///
  /// The [limitToFirst] method is used to set a maximum number of children to be
  /// synced for a given callback.
  QueryPlatform limitToFirst(int limit) {
    throw UnimplementedError("limitToFirst() is not implemented");
  }

  /// Generates a new [QueryPlatform] limited to the last specific number of children.
  ///
  /// The [limitToLast] method is used to set a maximum number of children to be
  /// synced for a given callback.
  QueryPlatform limitToLast(int limit) {
    throw UnimplementedError("limitToLast() is not implemented");
  }

  /// Listens for exactly one event of the specified event type, and then stops listening.
  Future<DataSnapshotPlatform> once() async {
    throw UnimplementedError("once() is not implemented");
  }

  /// This [Stream] will be triggered once for each initial child at this location,
  /// and it will be triggered again every time a new child is added, changed,
  /// moved or removed.
  ///
  /// To only recieve snapshots for specific child events, see [onChildAdded],
  /// [onChildRemoved], [onChildChanged] & [onChildMoved].
  Stream<DataSnapshotPlatform> get onChildEvent {
    throw UnimplementedError("onChildEvent is not implemented");
  }

  /// This [Stream] will be triggered once for each initial child at this location,
  /// and it will be triggered again every time a new child is added.
  Stream<DataSnapshotPlatform> get onChildAdded {
    throw UnimplementedError("onChildAdded is not implemented");
  }

  /// This [Stream] will be triggered once every time a child is removed.
  /// The [DataSnapshotPlatform] passed into the stream will be the old data for the
  /// child that was removed.
  ///
  /// A child will get removed when either:
  ///   - a client explicitly calls [remove] on that child or one of its ancestors
  ///   - a client calls [set] with `null` on that child or one of its ancestors
  ///   - that child has all of its children removed
  ///   - there is a query in effect which now filters out the child (because
  ///     it's sort order changed or the max limit was hit)
  Stream<DataSnapshotPlatform> get onChildRemoved {
    throw UnimplementedError("onChildRemoved is not implemented");
  }

  /// This [Stream] will be triggered when the data stored in a child (or any of its descendants) changes.
  ///
  /// Note that a single event may represent multiple changes to the child.
  /// The [DataSnapshotPlatform] passed to the callback will contain the new child contents.
  Stream<DataSnapshotPlatform> get onChildChanged {
    throw UnimplementedError("onChildChanged is not implemented");
  }

  /// This [Stream] will be triggered when a child's sort order changes such that
  /// its position relative to its siblings changes.
  Stream<DataSnapshotPlatform> get onChildMoved {
    throw UnimplementedError("onChildMoved is not implemented");
  }

  /// This [Stream] will trigger once with the initial data stored at this location,
  /// and then trigger again each time the data changes.
  ///
  /// The [DataSnapshotPlatform] passed to the callback will be for the location of the [Reference].
  /// It won't trigger until the entire contents has been synchronized. If
  /// the location has no data, it will be triggered with an empty [DataSnapshotPlatform].
  Stream<DataSnapshotPlatform> get onValue {
    throw UnimplementedError("onValue is not implemented");
  }

  /// Generates a new [QueryPlatform] object ordered by the specified child key.
  ///
  /// Queries can only order by one key at a time. Calling [orderByChild]
  /// multiple times on the same query is an error.
  ///
  /// Firebase queries allow you to order your data by any child key on the fly.
  /// However, if you know in advance what your indexes will be, you can define
  /// them via the `.indexOn` rule in your Security Rules for better performance.
  QueryPlatform orderByChild(String path) {
    throw UnimplementedError("orderByChild() is not implemented");
  }

  /// Generates a new [QueryPlatform] object ordered by key.
  ///
  ///Sorts the results of a query by their (ascending) key values
  QueryPlatform orderByKey() {
    throw UnimplementedError("orderByKey() is not implemented");
  }

  /// Generates a new [QueryPlatform] object ordered by priority.
  QueryPlatform orderByPriority() {
    throw UnimplementedError("orderByPriority() is not implemented");
  }

  /// Generates a new [QueryPlatform] object ordered by value.
  ///
  /// If the children of a query are all scalar values ([String], [num], or [bool]),
  /// you can order the results by their (ascending) values.
  QueryPlatform orderByValue() {
    throw UnimplementedError("orderByValue() is not implemented");
  }

  /// Creates a [QueryPlatform] with the specified starting point.
  ///
  /// Using [startAt], [endAt] and [equalTo] allows you to choose arbitrary
  /// starting and ending points for your queries.
  ///
  /// The starting point is inclusive, so children with exactly the specified value
  /// will be included in the query. The optional key argument can be used to further
  /// limit the range of the query. If it is specified, then children that have
  /// exactly the specified value must also have a key name less than or equal
  /// to the specified key.
  QueryPlatform startAt(dynamic /*?*/ value, String /*?*/ key) {
    throw UnimplementedError("startAt() is not implemented");
  }
}
