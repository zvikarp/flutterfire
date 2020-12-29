// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A class representing sentinal values which can be provided to the database
/// to perform atomic operations.
class ServerValue {
  /// A placeholder value for auto-populating the current timestamp (time since
  /// the Unix epoch, in milliseconds) as determined by the Firebase servers.
  static Map<String, String> get TIMESTAMP {
    return <String, String>{
      '.sv': 'timestamp',
    };
  }

  /// Returns a placeholder value that can be used to atomically increment the
  /// current database value by the provided delta.
  static Map<String, dynamic> increment(int /*!*/ delta) {
    return <String, dynamic>{
      '.sv': {
        'increment': delta,
      }
    };
  }
}
