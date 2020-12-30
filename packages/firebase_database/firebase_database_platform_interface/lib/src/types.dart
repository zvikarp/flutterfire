// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

/// A developer-supplied function which will be passed the current data stored
/// at this location. The function should return the new value it would like written
///
/// If a [AbortTransaction] exception is thrown, the transaction
/// will be aborted and the data at this location will not be modified.
typedef Future<T> TransactionHandler<T>(dynamic value);

/// An exception which can be thrown within a transaction, causing the operation
/// to be aborted.
class AbortTransaction implements Exception {}
