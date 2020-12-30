// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/internal/pointer.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_reference.dart';

/// The [MethodChannel] delegate implementation for [DataSnapshotPlatform].
class MethodChannelDataSnapshot extends DataSnapshotPlatform {
  final FirebaseDatabasePlatform _database;

  final String _ref;

  final Pointer _pointer;

  /// Constructs a new [MethodChannelDataSnapshot].
  MethodChannelDataSnapshot(
      this._database, this._ref, Map<String, dynamic> data)
      : _pointer = Pointer(_ref),
        super(_ref, data);

  @override
  ReferencePlatform /*!*/ get ref => MethodChannelReference(_database, _ref);

  @override
  DataSnapshotPlatform /*!*/ child(String /*!*/ path) {
    dynamic childData;

    // Check whether the path points to non-null data
    if (hasChild(path)) {
      childData = value[path];
    }

    return MethodChannelDataSnapshot(
        _database, _pointer.child(path).path, <String, dynamic>{
      'data': childData,
      'priority': null,
      'childKeys': childData is Map ? childData.keys.toList() : [],
    });
  }

  @override
  bool forEach(action) {
    bool canceled = false;

    if (value is List) {
      int i = 0;
      for (dynamic _ in value) {
        bool cancel = action(child(i.toString()), i);
        i++;
        if (cancel == true) {
          canceled = true;
          break;
        }
      }

      return canceled;
    }

    List<String> childKeys = getChildKeys();

    if (childKeys.isNotEmpty) {
      for (String childKey in childKeys) {
        int i = 0;
        bool cancel = action(child(childKey), i);
        i++;
        if (cancel == true) {
          canceled = true;
          break;
        }
      }
    }

    return canceled;
  }
}
