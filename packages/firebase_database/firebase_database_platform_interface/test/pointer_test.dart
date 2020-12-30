// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database_platform_interface/src/internal/pointer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Pointer', () {
    test('returns a path and components', () {
      expect(Pointer().path, '');
      expect(Pointer().components, []);
      expect(Pointer('/').path, '');
      expect(Pointer('/').components, []);
      expect(Pointer('foo/bar').path, 'foo/bar');
      expect(Pointer('foo/bar').components, ['foo', 'bar']);
    });

    test('returns a valid path', () {
      expect(Pointer('foo').path, 'foo');
      expect(Pointer('/foo').path, 'foo');
      expect(Pointer('foo/').path, 'foo');
      expect(Pointer('foo/bar').path, 'foo/bar');
      expect(Pointer('/foo/bar').path, 'foo/bar');
      expect(Pointer('foo/bar/').path, 'foo/bar');
    });

    test('returns a valid key', () {
      expect(Pointer('').key, null);
      expect(Pointer('/').key, null);
      expect(Pointer('foo').key, 'foo');
      expect(Pointer('/foo').key, 'foo');
      expect(Pointer('foo/').key, 'foo');
      expect(Pointer('foo/bar').key, 'bar');
      expect(Pointer('/foo/bar').key, 'bar');
      expect(Pointer('foo/bar/').key, 'bar');
    });

    test('returns a valid parent path', () {
      expect(Pointer().parentPath(), null);
      expect(Pointer('/').parentPath(), null);
      expect(Pointer('foo').parentPath(), null);
      expect(Pointer('foo/bar').parentPath(), 'foo');
      expect(Pointer('foo/bar/baz').parentPath(), 'foo/bar');
    });

    test('returns a valid child path', () {
      expect(Pointer().child('foo').path, 'foo');
      expect(Pointer('/').child('foo').path, 'foo');
      expect(Pointer('foo').child('foo').path, 'foo/foo');
      expect(Pointer('foo/bar').child('foo').path, 'foo/bar/foo');
      expect(Pointer('/foo/bar/baz').child('foo').path, 'foo/bar/baz/foo');
      expect(Pointer('foo/bar/baz/').child('foo').path, 'foo/bar/baz/foo');
    });

    test('Pointer equality with un-normalized paths', () {
      expect(Pointer('foo') == Pointer('/foo'), true);
      expect(Pointer('foo') == Pointer('/foo/bar'), false);
      expect(Pointer('foo') == Pointer('foo/'), true);
      expect(Pointer('foo') == Pointer('foo/bar/'), false);
    });
  });
}
