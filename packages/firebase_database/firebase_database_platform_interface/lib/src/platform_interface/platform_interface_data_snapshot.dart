// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'package:firebase_database_platform_interface/src/internal/pointer.dart';

import 'platform_interface_reference.dart';

/// The action for a [DataSnapshotPlatform] [forEach] call.
typedef bool /*?*/ DataSnapshotForEach(
    DataSnapshotPlatform /*!*/ snapshot, int /*!*/ index);

/// Represents the event type of a [DataSnapshotPlatform].
enum DataSnapshotEvent {
  /// Indicates the snapshot was created from a child added event.
  onChildAdded,

  /// Indicates the snapshot was created from a child changed event.
  onChildChanged,

  /// Indicates the snapshot was created from a child removed event.
  onChildRemoved,

  /// Indicates the snapshot was created from a child moved event.
  onChildMoved,
}

/// A DataSnapshot contains data from a Database location.
///
/// Any time you read data from the Database, you receive the data as a [DataSnapshot].
/// A DataSnapshot is an efficiently generated, immutable copy of the data at a
/// Database location. It cannot be modified and will never change (to modify
/// data, you always call the [set] method on a [Reference] directly).
class DataSnapshotPlatform extends PlatformInterface {
  final Pointer _pointer;

  final DataSnapshotEvent _event;

  final Map<String, dynamic> _data;

  /// Constructs a new [DataSnapshotPlatform] instance.
  DataSnapshotPlatform(String ref, String /*?*/ event, this._data)
      : _event = _eventToEnum(event),
        _pointer = Pointer(ref),
        super(token: _token);

  /// Ensures delegate implementations of a [DataSnapshot] extend this class.
  static verifyExtends(DataSnapshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  static final Object _token = Object();

  static DataSnapshotEvent /*?*/ _eventToEnum(String /*?*/ event) {
    switch (event) {
      case "onChildAdded":
        return DataSnapshotEvent.onChildAdded;
      case "onChildChanged":
        return DataSnapshotEvent.onChildChanged;
      case "onChildRemoved":
        return DataSnapshotEvent.onChildRemoved;
      case "onChildMoved":
        return DataSnapshotEvent.onChildMoved;
      default:
        return null;
    }
  }

  /// The DataSnapshot event type for child events.
  DataSnapshotEvent get event {
    return _event;
  }

  /// The key (last part of the path) of the location of this [DataSnapshot].
  ///
  /// The last token in a Database location is considered its key. For example,
  /// "ada" is the key for the /users/ada/ node. Accessing the key on any
  /// [DataSnapshot] will return the key for the location that generated it.
  /// However, accessing the key on the root URL of a [Database] will return `null`.
  String /*?*/ get key {
    return _pointer.key;
  }

  /// The name of the previous child key by sort order, used for ordering purposes.
  ///
  /// This property is only exposed on child events and may be `null` if there was
  /// no previous child.
  String /*?*/ get previousChildName {
    return _data['previousChildName'];
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

  /// Exports the entire contents of the [DataSnapshot] as a [Map].
  ///
  /// This method returns the data and priority in such a way it is suitable
  /// for backing up your data.
  Map<String, dynamic> /*!*/ exportVal() {
    return <String, dynamic>{
      '.value': value,
      '.priority': getPriority(),
    };
  }

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

  /// A list of child keys for this [DataSnapshotPlatform].
  ///
  /// In cases where a [Map] is stored on the database, child keys are used
  /// for iteration with the [forEach] method to guarentee order.
  ///
  /// Note; this is not exposed to the user, instead they should call [forEach].
  List<String> getChildKeys() {
    return List.from(_data['childKeys']);
  }

  /// Returns true if the specified child path has (non-null) data.
  bool hasChild(String /*!*/ path) {
    if (!exists() || value is! Map) {
      return false;
    }

    return value is Map && value[path] != null;
  }

  /// Returns whether or not the [DataSnapshotPlatform] has any non-null child properties.
  bool hasChildren() {
    return numChildren() > 0;
  }

  /// Returns the number of child properties of this [DataSnapshotPlatform].
  int numChildren() {
    return _data['childKeys'] ?? 0;
  }
}
