// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A helper class to handle Database paths.
///
/// This class is used internally to manage paths which point to a reference.
/// Since paths can be deeply nested, the class helps to reduce code repetition
/// and improve testability.
class Pointer {
  /// Create instance of [Pointer]
  Pointer([String /*?*/ path = ''])
      : components =
            path.split('/').where((element) => element.isNotEmpty).toList();

  /// Pointer components of the path.
  ///
  /// This is used to determine whether a path is a collection or document.
  final List<String> components;

  /// The full path to this pointer instance.
  String get path {
    return components.join('/');
  }

  /// Returns the key for this pointer.
  ///
  /// The key is the last component of a given path. For example, the ID of the
  /// document "user/123" is "123".
  String /*?*/ get key {
    if (components.isEmpty) {
      return null;
    }

    return components.last;
  }

  /// Returns a path pointing to the parent of the current path.
  String /*?*/ parentPath() {
    if (components.length < 2) {
      return null;
    }

    List<String> parentComponents = List<String>.from(components)..removeLast();
    return parentComponents.join('/');
  }

  /// Returns a [Pointer] to a child node of the current path.
  Pointer child(String /*!*/ childPath) {
    Pointer _pointer = Pointer(childPath);
    return Pointer("$path/${_pointer.path}");
  }

  @override
  bool operator ==(dynamic o) => o is Pointer && o.path == path;

  @override
  int get hashCode => path.hashCode;
}
