// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'package:firebase_database_platform_interface/src/internal/pointer.dart';

import 'platform_interface_reference.dart';

/// The action for a [DataSnapshotPlatform] [forEach] call.
typedef bool /*?*/ DataSnapshotForEach(DataSnapshotPlatform /*!*/ snapshot);

/// A DataSnapshot contains data from a Database location.
///
/// Any time you read data from the Database, you receive the data as a [DataSnapshot].
/// A DataSnapshot is an efficiently generated, immutable copy of the data at a
/// Database location. It cannot be modified and will never change (to modify
/// data, you always call the [set] method on a [Reference] directly).
class DataSnapshotPlatform extends PlatformInterface {
  final Pointer _pointer;

  final Map<String, dynamic> _data;

  /// Constructs a new [DataSnapshotPlatform] instance.
  DataSnapshotPlatform(String path, this._data)
      : _pointer = Pointer(path),
        super(token: _token);

  /// Ensures delegate implementations of a [DataSnapshot] extend this class.
  static verifyExtends(DataSnapshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  static final Object _token = Object();

  /// The key (last part of the path) of the location of this [DataSnapshot].
  ///
  /// The last token in a Database location is considered its key. For example,
  /// "ada" is the key for the /users/ada/ node. Accessing the key on any
  /// [DataSnapshot] will return the key for the location that generated it.
  /// However, accessing the key on the root URL of a [Database] will return `null`.
  String /*?*/ get key {
    return _pointer.key;
  }

  /// The [ReferencePlatform] for the location that generated this [DataSnapshotPlatform].
  ReferencePlatform get ref {
    throw UnimplementedError("ref is not implemented");
  }

  /// Extracts the data from the current [DataSnapshotPlatform].
  dynamic get value => _data['data'];

  /// Gets another [DataSnapshotPlatform] for the location at the specified relative path.
  ///
  /// Passing a relative path to the [child] method of a DataSnapshot returns
  /// another DataSnapshot for the location at the specified relative path.
  /// The relative path can either be a simple child name (for example, "ada")
  /// or a deeper, slash-separated path (for example, "ada/name/first").
  /// If the child location has no data, an empty [DataSnapshotPlatform] (that is,
  /// a [DataSnapshotPlatform] whose [value] is `null`) is returned.
  DataSnapshotPlatform /*?*/ child(String /*!*/ path) {
    throw UnimplementedError("child() is not implemented");
  }

  /// Returns `true` if this [DataSnapshotPlatform] contains any data.
  bool exists() {
    return _data['data'] != null;
  }

  // exportVal?

  /// Enumerates the top-level children in the [DataSnapshotPlatform].
  ///
  /// Because of the way objects work, the ordering of data in the object
  /// returned by [value] is not guaranteed to match the ordering on the
  /// server nor the ordering of [onChildAdded] events. That is where [forEach]
  /// comes in handy. It guarantees the children of a [DataSnapshotPlatform] will
  /// be iterated in their query order.
  ///
  /// If `true` is returned from an action iteraction, the iteration will be
  /// canceled and `true` will be returned from [forEach].
  bool /*!*/ forEach(DataSnapshotForEach action) {
    throw UnimplementedError("forEach() is not implemented");
  }

  /// Gets the priority value of the data in this [DataSnapshotPlatform].
  dynamic getPriority() {
    return _data['priority'];
  }

  /// Returns true if the specified child path has (non-null) data.
  bool hasChild(String /*!*/ path) {
    if (!exists() || value is! Map) {
      return false;
    }

    return value[path] == null ? false : true;
  }

  /// Returns whether or not the [DataSnapshotPlatform] has any non-null child properties.
  bool hasChildren() {
    return numChildren() > 0;
  }

  /// Returns the number of child properties of this [DataSnapshotPlatform].
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
