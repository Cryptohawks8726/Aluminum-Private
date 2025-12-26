// this file is a LOT of boilerplate and comments
import 'dart:async';
import 'dart:ffi';

import 'package:driver_dashboard/ntcore/abi.dart';
import 'package:driver_dashboard/ntcore/ntcore_structs.dart';
import 'package:driver_dashboard/ntcore/values.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// A NetworkTables client. Uses the ntcore library from WPILib.
/// You should only need one instance object at any given time.
/// See the WPILib C++ docs on ntcore's C api (ntcore_c.h) for
/// more info.
class NTInstance {
  final int _inst = NTCoreABI.ntCreateInstance();
  // if polling gets bad enough we can move it to an isolate but that seems unnecessary.
  late final _listenerPoller = NTCoreABI.ntCreateListenerPoller(_inst);
  late final Pointer<WPIString> _connectionName;

  bool stopTimer = false;

  /// Creates a new instance connected to the specific team number and port
  /// and with the given name.
  /// Port and team number can be changed later.
  NTInstance({
    int teamNumber = 8726,
    int port = 5810,
    name = "8726DriverDashboard",
  }) {
    _connectionName = toWpiString(name);
    NTCoreABI.ntStartClient4(_inst, _connectionName);
    NTCoreABI.ntSetServerTeam(_inst, teamNumber, port);
    // starts polling listeners (at 20 ms intervals)
    Timer.periodic(const Duration(milliseconds: 20), _pollListeners);
  }

  /// Called periodically to receive any updates from listeners.
  void _pollListeners(Timer timer) {
    if (stopTimer) {
      timer.cancel();
      return;
    }
    var len = calloc.allocate<Size>(sizeOf<Size>());
    var queue = NTCoreABI.ntReadListenerQueue(_listenerPoller, len);

    if (queue.address == 0) {
      return; // The function returns a null pointer when there are no events.
    }

    for (int i = 0; i < len.value; i++) {
      // assume events are value events since those are the only ones
      // we usually subscribe to. CHANGE THIS IF YOU WANT TO LISTEN TO OTHER EVENTS!

      var event = queue[i];
      var name = calloc.allocate<WPIString>(sizeOf<WPIString>());
      NTCoreABI.ntGetTopicName(event.data.valueData.topic, name);
      // just in case this is null
      if (name.ref.str.address == 0) {
        calloc.free(name);
        return;
      }
      var nameDart = wpiToDartString(name);
      calloc.free(name);
      // don't think freeCharArray is needed here? maybe double check that later
      NTValueNotifier? maybeNotifier =
          NTValueNotifier._activeListeners[nameDart];
      if (maybeNotifier != null) {
        maybeNotifier._updateValue(_cValueToDart(event.data.valueData.value));
      }
    }

    NTCoreABI.ntDisposeEventArray(queue, len.value);
  }

  /// Frees resources in use by this instance. Failing to call this before
  /// the object is destroyed will cause a slight memory leak. (If you never destroy this
  /// object you won't need to call this.)
  void dispose() {
    stopTimer = true;
    NTCoreABI.ntDestroyListenerPoller(_listenerPoller);
    NTCoreABI.ntDestroyInstance(_inst);
    calloc.free(_connectionName);
  }

  /// Sets the team number and port used to connect to the rio, without
  /// restarting the client. This is already done when the object is first constructed
  /// so only call this if the connection settings need to be changed.
  void updateConnectionSettings(int team, int port) {
    if (port > 0) {
      NTCoreABI.ntSetServerTeam(_inst, team, port);
    }
  }

  /// Sets the server name and port used to connect to the NetworkTables server.
  /// It is generally recommended to use updateConnectionSettings for normal
  /// operation but if you pass localhost and 5810 to this you can connect to
  /// the sim GUI. Otherwise this works the same as updateConnectionSettings
  void updateServerNamePort(String serverName, int port) {
    if (port > 0) {
      NTCoreABI.ntSetServer(_inst, toWpiString(serverName), port);
    }
  }

  /// Fetches the value of an entry.
  NetworkTablesValue getEntryValue(String entryName) {
    var entryHandle = NTCoreABI.ntGetEntry(_inst, toWpiString(entryName));
    var value = calloc.allocate<NTValue>(sizeOf<NTValue>());
    NTCoreABI.ntGetEntryValue(entryHandle, value);
    NTCoreABI.ntReleaseEntry(entryHandle);
    var out = _cValueToDart(value.ref);
    NTCoreABI.ntDisposeValue(value);
    calloc.free(value);
    return out;
  }

  // TODO: write all the other ones, and test these.
  /// Sets a boolean value in NetworkTables.
  void setEntryBool(String entryName, bool val) {
    var entryHandle = NTCoreABI.ntGetEntry(_inst, toWpiString(entryName));
    NTCoreABI.ntSetBoolean(entryHandle, 0, val ? 1 : 0);
    NTCoreABI.ntReleaseEntry(entryHandle);
  }
}

/// A class which notifies any listeners any time a value in NetworkTables
/// changes. See the flutter documentation of ChangeNotifier for more information
/// on how to use this.
class NTValueNotifier with ChangeNotifier {
  static final _activeListeners = <String, NTValueNotifier>{};
  NetworkTablesValue _currentValue = NTUnassignedValue(0, 0);
  NetworkTablesValue get currentValue => _currentValue;
  final int entryHandle;
  final int listenerHandle;

  NTValueNotifier({required this.entryHandle, required this.listenerHandle});

  /// Stops listening to and notifying changes to a certain value
  /// in NetworkTables, releasing any resources being used to do
  /// so.
  static void stopNotifying(String valueName) {
    var listener = _activeListeners[valueName];
    if (listener != null) {
      NTCoreABI.ntRemoveListener(listener.listenerHandle);
      _activeListeners.remove(valueName);
    }
  }

  factory NTValueNotifier.fromName({
    required String valueName,
    required NTInstance inst,
  }) {
    NTValueNotifier? maybeCached = _activeListeners[valueName];
    if (maybeCached != null) {
      return maybeCached;
    }

    var handle = NTCoreABI.ntGetEntry(inst._inst, toWpiString(valueName));
    var listenerHandle = NTCoreABI.ntAddPolledListener(
      inst._listenerPoller,
      handle,
      ntEventValueAll,
    );

    var notifier = NTValueNotifier(
      entryHandle: handle,
      listenerHandle: listenerHandle,
    );
    _activeListeners[valueName] = notifier;

    return notifier;
  }

  void _updateValue(NetworkTablesValue newValue) {
    _currentValue = newValue;
    notifyListeners();
  }
}

// this method is messy but mostly copied + pasted a lot.
// you can use all the funtcions to get data out of a value but it's
// literally just more effort for no reason.
/// Converts an NTValue struct into a NetworkTablesValue object.
/// This copies data from the NT_Value struct. You should ensure
/// any memory from the struct is freed after calling this function.
NetworkTablesValue _cValueToDart(NTValue value) {
  NetworkTablesValue out;

  // note: Pointer<Utf8>.toDartString() does NOT rely on existing memory
  // but the arrays do, so they must be copied.
  switch (value.type) {
    case ntTypeBoolean:
      out = NTBooleanValue(
        value.lastChange,
        value.serverTime,
        value.data.vBoolean == 1,
      );
      break;
    case ntTypeDouble:
      out = NTDoubleValue(
        value.lastChange,
        value.serverTime,
        value.data.vDouble,
      );
      break;
    case ntTypeFloat:
      out = NTDoubleValue(
        value.lastChange,
        value.serverTime,
        value.data.vFloat,
      );
      break;
    case ntTypeInteger:
      out = NTIntegerValue(value.lastChange, value.serverTime, value.data.vInt);
      break;
    case ntTypeString:
      out = NTStringValue(
        value.lastChange,
        value.serverTime,
        value.data.vString.str.toDartString(length: value.data.vString.len),
      );
      break;
    case ntTypeRaw:
      var rawArr = value.data.vRaw.data.asTypedList(value.data.vRaw.size);
      out = NTRawValue(value.lastChange, value.serverTime, List.from(rawArr));
      break;
    case ntTypeBooleanArray:
      var arrPtr = value.data.arrBoolean.arr;
      var newArr = <bool>[];
      for (int i = 0; i < value.data.arrBoolean.size; i++) {
        newArr.add(arrPtr[i] == 1);
      }
      out = NTBooleanArrayValue(value.lastChange, value.serverTime, newArr);
      break;
    case ntTypeIntegerArray:
      var arr = value.data.arrInt.arr.asTypedList(value.data.arrInt.size);
      out = NTIntegerArrayValue(
        value.lastChange,
        value.serverTime,
        List.from(arr),
      );
      break;
    case ntTypeFloatArray:
      var arr = value.data.arrFloat.arr.asTypedList(value.data.arrFloat.size);
      out = NTDoubleArrayValue(
        value.lastChange,
        value.serverTime,
        List.from(arr),
      );
      break;
    case ntTypeDoubleArray:
      var arr = value.data.arrDouble.arr.asTypedList(value.data.arrDouble.size);
      out = NTDoubleArrayValue(
        value.lastChange,
        value.serverTime,
        List.from(arr),
      );
      break;
    case ntTypeStringArray:
      var stringArr = value.data.arrString.arr;
      var newList = <String>[];
      for (int i = 0; i < value.data.arrString.size; i++) {
        var wpi = stringArr[i];
        newList.add(wpi.str.toDartString(length: wpi.len));
      }
      out = NTStringArrayValue(value.lastChange, value.serverTime, newList);
      break;

    // Will return an unassigned value if it's either an unassigned value or broken.
    default:
      out = NTUnassignedValue(value.lastChange, value.serverTime);
      break;
  }

  return out;
}
