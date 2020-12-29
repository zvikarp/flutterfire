// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

class MethodChannelDataSnapshot extends DataSnapshotPlatform {
  final FirebaseDatabasePlatform _database;
  final String _path;

  MethodChannelDataSnapshot(
      this._database, this._path, Map<String, dynamic> data)
      : super(_database, _path, data);

  @override
  ReferencePlatform get ref => MethodChannelReference(); // TODO

  @override
  DataSnapshotPlatform child(String path) {
    // TODO - path with child, and data object to pass down?
    return MethodChannelDataSnapshot(_database, _path, {

    }); 
  }
}
