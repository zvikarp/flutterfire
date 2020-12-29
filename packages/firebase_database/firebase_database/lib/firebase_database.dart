// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_database;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

export 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart'
    show ServerValue;
export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;

part 'src/database.dart';
part 'src/reference.dart';
part 'src/query.dart';
part 'src/on_disconnect.dart';
part 'src/data_snapshot.dart';

bool _isValidPriority(dynamic value) {
  return value == null || value is int || value is String;
}

_assertPriority(dynamic value) {
  assert(_isValidPriority(value),
      "Priority value must be one of [String], [num], [bool] or [null]");
}
