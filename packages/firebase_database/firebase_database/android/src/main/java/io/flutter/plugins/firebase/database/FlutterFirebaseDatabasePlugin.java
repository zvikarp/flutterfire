// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.database;

import android.app.Activity;
import android.util.SparseArray;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.OnDisconnect;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.WeakHashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;

public class FlutterFirebaseDatabasePlugin implements FlutterFirebasePlugin, MethodChannel.MethodCallHandler, FlutterPlugin, ActivityAware {
  protected static final WeakHashMap<String, WeakReference<FirebaseDatabase>>
    databaseInstanceCache = new WeakHashMap<>();
  private static final SparseArray<ValueEventListener> valueEventListeners =
    new SparseArray<>();
  private final static String CHANNEL_NAME = "plugins.flutter.io/firebase_database";
  private final Map<String, EventChannel> eventChannels = new HashMap<>();
  private final Map<String, EventChannel.StreamHandler> streamHandlers = new HashMap<>();
  private boolean initialized = false;
  private MethodChannel channel;
  private EventChannel serverTimeOffsetEventChannel;
  private Activity activity;
  private BinaryMessenger binaryMessenger;

  public static void registerWith(PluginRegistry.Registrar registrar) {
    FlutterFirebaseDatabasePlugin instance = new FlutterFirebaseDatabasePlugin();
    instance.activity = registrar.activity();
    instance.initInstance(registrar.messenger());
  }

  public static Map<String, Object> dataSnapshotToMap(@NonNull DataSnapshot snapshot, @Nullable String previousChildName) {
    List<String> childKeys = new ArrayList<>();

    if (snapshot.hasChildren()) {
      for (DataSnapshot childSnapshot : snapshot.getChildren()) {
        childKeys.add(childSnapshot.getKey());
      }
    }

    HashMap<String, Object> map = new HashMap<>();
    map.put("previousChildName", previousChildName);
    map.put("priority", snapshot.getPriority());
    map.put("childKeys", childKeys);
    map.put("numChildren", snapshot.getChildrenCount());
    map.put("data", snapshot.getValue());

    return map;
  }

  protected static void setCachedFirebaseDatabaseInstanceForKey(
    FirebaseDatabase database, String key) {
    synchronized (databaseInstanceCache) {
      WeakReference<FirebaseDatabase> existingInstance = databaseInstanceCache.get(key);
      if (existingInstance == null) {
        databaseInstanceCache.put(key, new WeakReference<>(database));
      }
    }
  }

  private static void destroyCachedFirebaseDatabaseInstanceForKey(String key) {
    synchronized (databaseInstanceCache) {
      WeakReference<FirebaseDatabase> existingInstance = databaseInstanceCache.get(key);
      if (existingInstance != null) {
        existingInstance.clear();
        databaseInstanceCache.remove(key);
      }
    }
  }

  private void initInstance(BinaryMessenger messenger) {
    binaryMessenger = messenger;

    channel =
      new MethodChannel(
        messenger,
        CHANNEL_NAME);
    channel.setMethodCallHandler(this);

    serverTimeOffsetEventChannel = new EventChannel(messenger, CHANNEL_NAME + "/syncServerTimeOffset");

    FlutterFirebasePluginRegistry.registerPlugin(CHANNEL_NAME, this);
  }

  private void removeEventListeners() {
    // TODO remove any event listeners
  }

  private void attachToActivity(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  private void detachToActivity() {
    activity = null;
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    removeEventListeners();
    channel.setMethodCallHandler(null);
    channel = null;
    serverTimeOffsetEventChannel = null;
    binaryMessenger = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    attachToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    detachToActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(
    @NonNull ActivityPluginBinding activityPluginBinding) {
    attachToActivity(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    detachToActivity();
  }

  private FirebaseDatabase getDatabase(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get("appName"));
    FirebaseApp app = FirebaseApp.getInstance(appName);
    FirebaseDatabase database = FirebaseDatabase.getInstance(app);
    return database;
  }

  private DatabaseReference getReference(Map<String, Object> arguments) {
    String path = (String) Objects.requireNonNull(arguments.get("path"));
    FirebaseDatabase database = getDatabase(arguments);
    DatabaseReference reference = database.getReference(path);
    return reference;
  }

  private Query getQuery(Map<String, Object> arguments) {
    Query query = getReference(arguments);
    @SuppressWarnings("unchecked") List<Object> modifiers = (List<Object>) Objects.requireNonNull(arguments.get("modifiers"));

    for (Object m : modifiers) {
      @SuppressWarnings("unchecked") Map<String, Object> modifier = (Map<String, Object>) m;
      String type = (String) modifier.get("type");

      if ("orderBy".equals(type)) {
        query = applyOrderByModifier(query, modifier);
      } else if ("limit".equals(type)) {
        query = applyLimitModifier(query, modifier);
      } else if ("filter".equals(type)) {
        query = applyFilterModifier(query, modifier);
      }
    }

    return query;
  }

  Query applyOrderByModifier(Query query, Map<String, Object> modifier) {
    String name = (String) modifier.get("name");

    switch (name) {
      case "orderByKey":
        query = query.orderByKey();
        break;
      case "orderByPriority":
        query = query.orderByPriority();
        break;
      case "orderByValue":
        query = query.orderByValue();
        break;
      case "orderByChild":
        String key = (String) modifier.get("key");
        query = query.orderByChild(key);
    }

    return query;
  }

  Query applyLimitModifier(Query query, Map<String, Object> modifier) {
    String name = (String) modifier.get("name");
    int limit = (int) modifier.get("value");

    if ("limitToLast".equals(name)) {
      query = query.limitToLast(limit);
    } else if ("limitToFirst".equals(name)) {
      query = query.limitToFirst(limit);
    }

    return query;
  }

  Query applyFilterModifier(Query query, Map<String, Object> modifier) {
    String name = (String) modifier.get("name");

    if ("startAt".equals(name)) {
      query = applyStartAtModifier(query, modifier);
    } else if ("endAt".equals(name)) {
      query = applyEndAtModifier(query, modifier);
    }

    return query;
  }

  Query applyStartAtModifier(Query query, Map<String, Object> modifier) {
    String key = (String) modifier.get("key");
    String type = (String) modifier.get("valueType");

    switch (type) {
      case "string": {
        String value = (String) modifier.get("value");
        if (key == null) {
          query = query.startAt(value);
        } else {
          query = query.startAt(value, key);
        }
      }
      case "number": {
        double value = (Double) modifier.get("value");
        if (key == null) {
          query = query.startAt(value);
        } else {
          query = query.startAt(value, key);
        }
      }
      case "boolean": {
        boolean value = (Boolean) modifier.get("value");
        if (key == null) {
          query = query.startAt(value);
        } else {
          query = query.startAt(value, key);
        }
      }
      case "null": {
        if (key == null) {
          query = query.startAt(null);
        } else {
          query = query.startAt(null, key);
        }
      }
      default:
        break;
    }

    return query;
  }

  Query applyEndAtModifier(Query query, Map<String, Object> modifier) {
    String key = (String) modifier.get("key");
    String type = (String) modifier.get("valueType");

    switch (type) {
      case "string": {
        String value = (String) modifier.get("value");
        if (key == null) {
          query = query.endAt(value);
        } else {
          query = query.endAt(value, key);
        }
      }
      case "number": {
        double value = (Double) modifier.get("value");
        if (key == null) {
          query = query.endAt(value);
        } else {
          query = query.endAt(value, key);
        }
      }
      case "boolean": {
        boolean value = (Boolean) modifier.get("value");
        if (key == null) {
          query = query.endAt(value);
        } else {
          query = query.endAt(value, key);
        }
      }
      case "null": {
        if (key == null) {
          query = query.endAt(null);
        } else {
          query = query.endAt(null, key);
        }
      }
      default:
        break;
    }

    return query;
  }

  private Task<Void> databaseInit(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      if (initialized) return null;
      FirebaseDatabase database = getDatabase(arguments);
      DatabaseReference reference = database.getReference(".info/serverTimeOffset");
      serverTimeOffsetEventChannel.setStreamHandler(new ServerTimeOffsetStreamHandler(reference));
      initialized = true;
      return null;
    });
  }

  private Task<Void> goOffline(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      FirebaseDatabase database = getDatabase(arguments);
      database.goOffline();
      return null;
    });
  }

  private Task<Void> goOnline(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      FirebaseDatabase database = getDatabase(arguments);
      database.goOnline();
      return null;
    });
  }

  private Task<Void> referenceRemove(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      Tasks.await(reference.removeValue());
      return null;
    });
  }

  private Task<Void> referenceSet(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      Object value = arguments.get("value");
      Tasks.await(reference.setValue(value));
      return null;
    });
  }

  private Task<Void> referencePriority(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      Object priority = arguments.get("priority");
      Tasks.await(reference.setPriority(priority));
      return null;
    });
  }

  private Task<Void> referenceSetWithPriority(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      Object value = arguments.get("value");
      Object priority = arguments.get("priority");
      Tasks.await(reference.setValue(value, priority));
      return null;
    });
  }

  private Task<Void> referenceUpdate(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      @SuppressWarnings("unchecked") Map<String, Object> value = (Map<String, Object>) Objects.requireNonNull(arguments.get("value"));
      Tasks.await(reference.updateChildren(value));
      return null;
    });
  }

  private Task<String> addQueryListener(Map<String, Object> arguments, QueryStreamHandlerType type) {
    return Tasks.call(cachedThreadPool, () -> {
      String identifier = UUID.randomUUID().toString().toLowerCase(Locale.US);
      String eventChannelName = CHANNEL_NAME + "/" + identifier;

      EventChannel channel = new EventChannel(binaryMessenger, eventChannelName);
      EventChannel.StreamHandler handler = new QueryStreamHandler(getQuery(arguments), type);

      // TODO cleanup on reload/app restart etc
      eventChannels.put(identifier, channel);
      streamHandlers.put(identifier, handler);

      return identifier;
    });
  }

  private Task<Void> onDisconnectCancel(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      OnDisconnect onDisconnect = reference.onDisconnect();
      return Tasks.await(onDisconnect.cancel());
    });
  }

  private Task<Void> onDisconnectRemove(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      OnDisconnect onDisconnect = reference.onDisconnect();
      return Tasks.await(onDisconnect.removeValue());
    });
  }

  private Task<Void> onDisconnectSet(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      Object value = arguments.get("value");
      OnDisconnect onDisconnect = reference.onDisconnect();
      return Tasks.await(onDisconnect.setValue(value));
    });
  }

  private Task<Void> onDisconnectSetWithPriority(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      Object value = arguments.get("value");
      Object priority = arguments.get("priority");
      OnDisconnect onDisconnect = reference.onDisconnect();
      // TODO priority type? https://firebase.google.com/docs/reference/android/com/google/firebase/database/OnDisconnect?authuser=0
//      return Tasks.await(onDisconnect.setValue(value, priority));
      return null;
    });
  }

  private Task<Void> onDisconnectUpdate(Map<String, Object> arguments) {
    return Tasks.call(cachedThreadPool, () -> {
      DatabaseReference reference = getReference(arguments);
      @SuppressWarnings("unchecked") Map<String, Object> value = (Map<String, Object>) arguments.get("value");
      OnDisconnect onDisconnect = reference.onDisconnect();
      return Tasks.await(onDisconnect.updateChildren(value));
    });
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    Task<?> methodCallTask;

    switch (call.method) {
      case "Database#init":
        methodCallTask = databaseInit(call.arguments());
        break;
      case "Database#goOffline":
        methodCallTask = goOffline(call.arguments());
        break;
      case "Database#goOnline":
        methodCallTask = goOnline(call.arguments());
        break;
      case "Reference#remove":
        methodCallTask = referenceRemove(call.arguments());
        break;
      case "Reference#set":
        methodCallTask = referenceSet(call.arguments());
        break;
      case "Reference#setPriority":
        methodCallTask = referencePriority(call.arguments());
        break;
      case "Reference#setWithPriority":
        methodCallTask = referenceSetWithPriority(call.arguments());
        break;
      case "Reference#update":
        methodCallTask = referenceUpdate(call.arguments());
        break;
      case "Query#once":
        methodCallTask = addQueryListener(call.arguments(), QueryStreamHandlerType.once);
        break;
      case "Query#onValue":
        methodCallTask = addQueryListener(call.arguments(), QueryStreamHandlerType.onValue);
        break;
      case "Query#onChild":
        methodCallTask = addQueryListener(call.arguments(), QueryStreamHandlerType.onChild);
        break;
      case "OnDisconnect#cancel":
        methodCallTask = onDisconnectCancel(call.arguments());
        break;
      case "OnDisconnect#remove":
        methodCallTask = onDisconnectRemove(call.arguments());
        break;
      case "OnDisconnect#set":
        methodCallTask = onDisconnectSet(call.arguments());
        break;
      case "OnDisconnect#setWithPriority":
        methodCallTask = onDisconnectSetWithPriority(call.arguments());
        break;
      case "OnDisconnect#update":
        methodCallTask = onDisconnectUpdate(call.arguments());
        break;
      default:
        result.notImplemented();
        return;
    }

    methodCallTask.addOnCompleteListener(task -> {
      if (task.isSuccessful()) {
        result.success(task.getResult());
      } else {
        Exception exception = task.getException();
        // TODO(ehesp): Error details
        result.error("firebase_database", exception != null ? exception.getMessage() : null, null);
      }
    });
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return Tasks.call(cachedThreadPool, () -> null);
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        removeEventListeners();
        // Context is ignored by API so we don't send it over even though annotated non-null.

        for (FirebaseApp app : FirebaseApp.getApps(null)) {
          FirebaseDatabase database = FirebaseDatabase.getInstance(app);
          FlutterFirebaseDatabasePlugin.destroyCachedFirebaseDatabaseInstanceForKey(
            app.getName());
        }
        return null;
      });

  }

  // TODO ensure this is working and being called
  static class ServerTimeOffsetStreamHandler implements EventChannel.StreamHandler {
    final private DatabaseReference reference;
    private ValueEventListener listener;

    ServerTimeOffsetStreamHandler(DatabaseReference reference) {
      this.reference = reference;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
      listener = new ValueEventListener() {
        @Override
        public void onDataChange(@NonNull DataSnapshot snapshot) {
          int serverTimeOffset = (int) snapshot.getValue();
          events.success(serverTimeOffset);
        }

        @Override
        public void onCancelled(@NonNull DatabaseError error) {
          // TODO - convert error details from DatabaseError
          events.error("firebase_database", null, null);
        }
      };

      reference.addValueEventListener(listener);
    }

    @Override
    public void onCancel(Object arguments) {
      reference.removeEventListener(listener);
    }
  }
}
