// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// The action for a [DataSnapshot] [forEach] call.
typedef bool /*?*/ DataSnapshotForEach(DataSnapshot /*!*/ snapshot);

/// A DataSnapshot contains data from a Database location.
///
/// Any time you read data from the Database, you receive the data as a [DataSnapshot].
/// A DataSnapshot is an efficiently generated, immutable copy of the data at a
/// Database location. It cannot be modified and will never change (to modify
/// data, you always call the [set] method on a [Reference] directly).
class DataSnapshot {
  final FirebaseDatabase _database;

  final DataSnapshotPlatform _delegate;

  DataSnapshot._(this._database, this._delegate) {
    DataSnapshotPlatform.verifyExtends(_delegate);
  }

  /// The key (last part of the path) of the location of this [DataSnapshot].
  ///
  /// The last token in a Database location is considered its key. For example,
  /// "ada" is the key for the /users/ada/ node. Accessing the key on any
  /// [DataSnapshot] will return the key for the location that generated it.
  /// However, accessing the key on the root URL of a [Database] will return `null`.
  String /*?*/ get key => _delegate.key;

  /// The [Reference] for the location that generated this [DataSnapshot].
  Reference get ref => Reference._(_database, _delegate.ref);

  /// Extracts the data from the current [DataSnapshot].
  dynamic /*?*/ get value => _delegate.value;

  /// Gets another [DataSnapshot] for the location at the specified relative path.
  ///
  /// Passing a relative path to the [child] method of a DataSnapshot returns
  /// another DataSnapshot for the location at the specified relative path.
  /// The relative path can either be a simple child name (for example, "ada")
  /// or a deeper, slash-separated path (for example, "ada/name/first").
  /// If the child location has no data, an empty [DataSnapshot] (that is,
  /// a [DataSnapshot] whose [value] is `null`) is returned.
  DataSnapshot child(String /*!*/ path) {
    _assertChildPath(path);
    return DataSnapshot._(_database, _delegate.child(path));
  }

  /// Returns `true` if this [DataSnapshot] contains any data.
  bool /*?*/ exists() => _delegate.exists();

  /// Enumerates the top-level children in the [DataSnapshot].
  /// 
  /// Because of the way objects work, the ordering of data in the object
  /// returned by [value] is not guaranteed to match the ordering on the 
  /// server nor the ordering of [onChildAdded] events. That is where [forEach] 
  /// comes in handy. It guarantees the children of a [DataSnapshot] will
  /// be iterated in their query order.
  /// 
  /// If `true` is returned from an action iteraction, the iteration will be
  /// canceled and `true` will be returned from [forEach].
  bool forEach(DataSnapshotForEach action) {
    // TODO: ehesp
  }

  /// Gets the priority value of the data in this [DataSnapshot].
  dynamic getPriority() => _delegate.getPriority();

  /// Returns true if the specified child path has (non-null) data.
  bool hasChild(String /*!*/ path) {
    _assertChildPath(path);
    return _delegate.hasChild(path);
  }

  /// Returns whether or not the [DataSnapshot] has any non-null child properties.
  bool hasChildren() => _delegate.hasChildren();

  /// Returns the number of child properties of this [DataSnapshot].
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
