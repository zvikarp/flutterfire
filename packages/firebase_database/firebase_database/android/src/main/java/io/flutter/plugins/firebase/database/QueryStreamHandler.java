// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.firebase.database.ChildEventListener;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

import static io.flutter.plugins.firebase.database.FlutterFirebaseDatabasePlugin.dataSnapshotToMap;

enum QueryStreamHandlerType {
  once,
  onValue,
  onChild,
}

class QueryStreamHandler implements EventChannel.StreamHandler {
  final private Query query;
  final private QueryStreamHandlerType type;

  private ValueEventListener valueListener;
  private ChildEventListener childListener;

  QueryStreamHandler(Query query, QueryStreamHandlerType type) {
    this.query = query;
    this.type = type;
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    switch (type) {
      case once:
        once(events);
        break;
      case onValue:
        valueListener = onValueEvent(events);
        break;
      case onChild:
        childListener = onChildEvent(events);
        break;
    }
  }

  private Map<String, Object> eventToMap(@NonNull DataSnapshot snapshot, @Nullable String previousChildName, @Nullable String event) {
    HashMap<String, Object> map = new HashMap<>();
    map.put("event", event);
    map.put("snapshot", dataSnapshotToMap(snapshot, previousChildName));

    return map;
  }

  ValueEventListener getValueEventListener(EventChannel.EventSink events) {
    return new ValueEventListener() {
      @Override
      public void onDataChange(@NonNull DataSnapshot snapshot) {
        events.success(eventToMap(snapshot, null, null));
      }

      @Override
      public void onCancelled(@NonNull DatabaseError error) {
        // TODO
        events.error("firebase_database", null, null);
      }
    };
  }

  ChildEventListener getChildEventListener(EventChannel.EventSink events) {
    return new ChildEventListener() {
      @Override
      public void onChildAdded(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
        events.success(eventToMap(snapshot, previousChildName, "onChildAdded"));
      }

      @Override
      public void onChildChanged(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
        events.success(eventToMap(snapshot, previousChildName, "onChildChanged"));
      }

      @Override
      public void onChildRemoved(@NonNull DataSnapshot snapshot) {
        events.success(eventToMap(snapshot, null, "onChildRemoved"));
      }

      @Override
      public void onChildMoved(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
        events.success(eventToMap(snapshot, previousChildName, "onChildMoved"));
      }

      @Override
      public void onCancelled(@NonNull DatabaseError error) {
        events.error("firebase_database", null, null);
      }
    };
  }

  void once(EventChannel.EventSink events) {
    query.addListenerForSingleValueEvent(getValueEventListener(events));
  }

  ValueEventListener onValueEvent(EventChannel.EventSink events) {
    return query.addValueEventListener(getValueEventListener(events));
  }

  ChildEventListener onChildEvent(EventChannel.EventSink events) {
    return query.addChildEventListener(getChildEventListener(events));
  }

  @Override
  public void onCancel(Object arguments) {
    if (valueListener != null) {
      query.removeEventListener(valueListener);
    }

    if (childListener != null) {
      query.removeEventListener(childListener);
    }
  }
}
