// this file is a LOT of boilerplate and comments
import 'dart:async';
import 'dart:ffi';

import 'package:aluminum/ntcore/library_link.dart';
import 'package:aluminum/ntcore/ntcore.g.dart';
import 'package:aluminum/ntcore/values.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

// These two enums are copied by hand, since invalid types caused ffigen enums
// to crash in one spot.
// enum NT_Type
const ntTypeUnassigned = 0;
const ntTypeBoolean = 0x01;
const ntTypeDouble = 0x02;
const ntTypeString = 0x04;
const ntTypeRaw = 0x08;
const ntTypeBooleanArray = 0x10;
const ntTypeDoubleArray = 0x20;
const ntTypeStringArray = 0x40;
const ntTypeRPC = 0x80;
const ntTypeInteger = 0x100;
const ntTypeFloat = 0x200;
const ntTypeIntegerArray = 0x400;
const ntTypeFloatArray = 0x800;

// enum NT_EventFlags
const ntEventNone = 0;
const ntEventImmediate = 0x01;
const ntEventConnected = 0x02;
const ntEventDisconnected = 0x04;
const ntEventConnection = ntEventConnected | ntEventDisconnected;
const ntEventPublish = 0x08;
const ntEventUnpublish = 0x10;
const ntEventProperties = 0x20;
const ntEventTopic = ntEventPublish | ntEventUnpublish | ntEventProperties;
const ntEventValueRemote = 0x40;
const ntEventValueLocal = 0x80;
const ntEventValueAll = ntEventValueRemote | ntEventValueLocal;
const ntEventLogMessage = 0x100;
const ntEventTimeSync = 0x200;

/// A NetworkTables client. Uses the ntcore library from WPILib.
/// You should only need one instance object at any given time.
/// See the WPILib C++ docs on ntcore's C api (ntcore_c.h) for
/// more info.
class NTInstance {
  final int _inst = ntcore.NT_CreateInstance();
  // if polling gets bad enough we can move it to an isolate but that seems unnecessary.
  late final _listenerPoller = ntcore.NT_CreateListenerPoller(_inst);
  late final Pointer<WPI_String> _connectionName;

  /// Cache of used handles. They can be forcibly freed but you likely won't need to.
  final Map<String, int> _handlesInUse = {};

  /// map
  final List<NTPrefixNotifier> _prefixListeners = [];

  /// Connection notifier - you can listen to this to be notified when there
  /// is a change in network connection status.
  final NTConnectionNotifier connectionNotifier = NTConnectionNotifier();

  bool _stopTimer = false;

  /// Creates a new instance connected to the specific team number and port
  /// and with the given name.
  /// Port and team number can be changed later.
  NTInstance({
    int teamNumber = 8726,
    int port = 5810,
    name = "8726DriverDashboard",
  }) {
    _connectionName = toWpiString(name);
    ntcore.NT_StartClient4(_inst, _connectionName);
    ntcore.NT_SetServerTeam(_inst, teamNumber, port);
    // starts polling listeners (at 20 ms intervals)
    Timer.periodic(const Duration(milliseconds: 20), _pollListeners);
  }

  /// Called periodically to receive any updates from listeners.
  void _pollListeners(Timer timer) {
    if (_stopTimer) {
      timer.cancel();
      return;
    }

    // Update connection info too since it's convenient to do here.
    connectionNotifier.isConnected = ntcore.NT_IsConnected(_inst) == 1;

    // Handle any prefix listeners.
    for (var listener in _prefixListeners) {
      final len = calloc.allocate<Size>(sizeOf<Size>());
      final queue = ntcore.NT_ReadListenerQueue(listener._listenerPoller, len);

      if (queue.address == 0) {
        continue; // The function returns a null pointer when there are no events.
      }

      for (int i = 0; i < len.value; i++) {
        final event = queue[i];
        final name = calloc.allocate<WPI_String>(sizeOf<WPI_String>());
        ntcore.NT_GetTopicName(event.data.valueData.topic, name);
        // just in case this is null
        if (name.ref.str.address == 0) {
          calloc.free(name);
          return;
        }
        final nameDart = wpiToDartString(name);
        calloc.free(name);

        listener._update(nameDart, _cValueToDart(event.data.valueData.value));
      }
      ntcore.NT_DisposeEventArray(queue, len.value);
    }

    final len = calloc.allocate<Size>(sizeOf<Size>());
    final queue = ntcore.NT_ReadListenerQueue(_listenerPoller, len);

    if (queue.address == 0) {
      return; // The function returns a null pointer when there are no events.
    }

    for (int i = 0; i < len.value; i++) {
      // assume events are value events since those are the only ones
      // we usually subscribe to. CHANGE THIS IF YOU WANT TO LISTEN TO OTHER EVENTS!

      final event = queue[i];
      final name = calloc.allocate<WPI_String>(sizeOf<WPI_String>());
      ntcore.NT_GetTopicName(event.data.valueData.topic, name);
      // just in case this is null
      if (name.ref.str.address == 0) {
        calloc.free(name);
        return;
      }
      final nameDart = wpiToDartString(name);
      // print('Received event for $nameDart');
      calloc.free(name);
      // don't think freeCharArray is needed here? maybe double check that later
      NTValueNotifier? maybeNotifier =
          NTValueNotifier._activeListeners[nameDart];
      if (maybeNotifier != null) {
        maybeNotifier._updateValue(_cValueToDart(event.data.valueData.value));
      }
    }

    ntcore.NT_DisposeEventArray(queue, len.value);
  }

  /// Frees resources in use by this instance. Failing to call this before
  /// the object is destroyed will cause a slight memory leak. (If you never destroy this
  /// object you won't need to call this.)
  void dispose() {
    _stopTimer = true;
    ntcore.NT_DestroyListenerPoller(_listenerPoller);
    ntcore.NT_DestroyInstance(_inst);
    calloc.free(_connectionName);
  }

  /// Sets the team number and port used to connect to the rio, without
  /// restarting the client. This is already done when the object is first constructed
  /// so only call this if the connection settings need to be changed.
  void updateConnectionSettings(int team, int port) {
    if (port > 0) {
      ntcore.NT_SetServerTeam(_inst, team, port);
    }
  }

  /// Sets the server name and port used to connect to the NetworkTables server.
  /// It is generally recommended to use updateConnectionSettings for normal
  /// operation but if you pass localhost and 5810 to this you can connect to
  /// the sim GUI. Otherwise this works the same as updateConnectionSettings
  void updateServerNamePort(String serverName, int port) {
    if (port > 0) {
      ntcore.NT_SetServer(_inst, toWpiString(serverName), port);
    }
  }

  /// Fetches the value of an entry.
  NetworkTablesValue getEntryValue(String entryName) {
    var entryHandle = _getEntryHandle(entryName);
    var value = calloc.allocate<NT_Value>(sizeOf<NT_Value>());
    ntcore.NT_GetEntryValue(entryHandle, value);
    ntcore.NT_ReleaseEntry(entryHandle);
    var out = _cValueToDart(value.ref);
    ntcore.NT_DisposeValue(value);
    calloc.free(value);
    return out;
  }

  // TODO: write all the other ones, and test these.
  /// Sets a boolean value in NetworkTables.
  void setEntryBool(String entryName, bool val) {
    ntcore.NT_SetBoolean(_getEntryHandle(entryName), 0, val ? 1 : 0);
  }

  void setEntryDouble(String entryName, double val) {
    ntcore.NT_SetDouble(_getEntryHandle(entryName), 0, val);
  }

  void setEntryDoubleArray(String entryName, List<double> val) {
    // Requires allocating a native array
    final ptr = calloc.allocate<Double>(sizeOf<Double>() * val.length);
    for (var i = 0; i < val.length; i++) {
      ptr[i] = val[i];
    }
    ntcore.NT_SetDoubleArray(_getEntryHandle(entryName), 0, ptr, val.length);
    calloc.free(ptr);
  }

  void setEntryString(String entryName, String val) {
    ntcore.NT_SetString(_getEntryHandle(entryName), 0, toWpiString(val));
  }

  void setEntryInt(String entryName, int val) {
    ntcore.NT_SetInteger(_getEntryHandle(entryName), 0, val);
  }

  void setEntryRaw(String entryName, Uint8List val) {
    final ptr = val.allocatePointer();
    ntcore.NT_SetRaw(_getEntryHandle(entryName), 0, ptr, val.lengthInBytes);
    calloc.free(ptr);
  }

  int _getEntryHandle(String entryName) {
    var maybeCached = _handlesInUse[entryName];
    if (maybeCached != null) {
      return maybeCached;
    } else {
      var newHandle = ntcore.NT_GetEntry(_inst, toWpiString(entryName));
      _handlesInUse[entryName] = newHandle;
      return newHandle;
    }
  }

  /// Frees the handle used to set or get values from a specific entry in NetworkTables, if
  /// there is one in use. Call this if you were setting a value or reading from it using
  /// getEntryValue and no longer need to.
  void freeEntryHandle(String entryName) {
    var maybeCached = _handlesInUse[entryName];
    if (maybeCached != null) {
      ntcore.NT_ReleaseEntry(maybeCached);
    }
  }
}

/// Similar to NTValueNotifier, but instead tracks all values under
/// a certain prefix and maintains a map of all the values contained under the prefix.
///
/// You should call `dispose` when you are done with this object.
class NTPrefixNotifier with ChangeNotifier {
  // private: nt handles (will be polled by the instance)
  late final int _listener;
  late final int _listenerPoller;

  final String prefix;
  final NTInstance instance;

  /// Map containing all of the entries. You are only intended to read from this, not edit it.
  /// This is a `Map<String, dynamic>` - the dynamic value will either be another
  /// Map or a NetworkTablesValue.
  final Map<String, dynamic> entries = {};

  NTPrefixNotifier({required this.prefix, required this.instance}) {
    _listenerPoller = ntcore.NT_CreateListenerPoller(instance._inst);
    final wpiPrefix = toWpiString(prefix);
    _listener = ntcore.NT_AddPolledListenerMultiple(
      _listenerPoller,
      wpiPrefix,
      1,
      ntEventValueAll,
    );
    ntcore.WPI_FreeString(wpiPrefix);

    instance._prefixListeners.add(this);
  }

  /// `path` must start with `prefix` or this may cause crashes.
  void _update(String path, NetworkTablesValue newVal) {
    var strippedPath = path.substring(prefix.length);
    if (strippedPath.startsWith('/')) {
      strippedPath = strippedPath.substring(1);
    }
    final strippedPathPieces = strippedPath.split('/');
    print('stripped path pieces: $strippedPathPieces');

    Map<String, dynamic> subTable = entries;
    for (var key in strippedPathPieces.getRange(
      0,
      strippedPathPieces.length - 1,
    )) {
      print('Searching for subtable $key');
      var newSubTable = entries[key];
      if (newSubTable == null) {
        print('not found, making new...');
        newSubTable = <String, dynamic>{};
        subTable[key] = newSubTable;
      }
      subTable = newSubTable;
    }
    print('Setting new value to table with key ${strippedPathPieces.last}');
    subTable[strippedPathPieces.last] = newVal;

    notifyListeners();
  }

  @override
  void dispose() {
    instance._prefixListeners.remove(this);
    ntcore.NT_RemoveListener(_listener);
    ntcore.NT_DestroyListenerPoller(_listenerPoller);
    super.dispose();
  }
}

/// Class which provides ChangeNotifier updates whenever the connection status changes.
class NTConnectionNotifier with ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  set isConnected(bool b) {
    if (_isConnected != b) {
      _isConnected = b;
      notifyListeners();
    }
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
      ntcore.NT_RemoveListener(listener.listenerHandle);
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

    var handle = ntcore.NT_GetEntry(inst._inst, toWpiString(valueName));
    var listenerHandle = ntcore.NT_AddPolledListener(
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
/// Converts an NT_Value struct into a NetworkTablesValue object.
/// This copies data from the NT_Value struct. You should ensure
/// any memory from the struct is freed after calling this function.
NetworkTablesValue _cValueToDart(NT_Value value) {
  NetworkTablesValue out;

  // note: Pointer<Utf8>.toDartString() does NOT rely on existing memory
  // but the arrays do, so they must be copied.
  switch (value.typeAsInt) {
    case ntTypeBoolean:
      out = NTBooleanValue(
        value.last_change,
        value.server_time,
        value.data.v_boolean == 1,
      );
      break;
    case ntTypeDouble:
      out = NTDoubleValue(
        value.last_change,
        value.server_time,
        value.data.v_double,
      );
      break;
    case ntTypeFloat:
      out = NTDoubleValue(
        value.last_change,
        value.server_time,
        value.data.v_float,
      );
      break;
    case ntTypeInteger:
      out = NTIntegerValue(
        value.last_change,
        value.server_time,
        value.data.v_int,
      );
      break;
    case ntTypeString:
      // Apparently this can return nullptr
      if (value.data.v_string.str.address != 0) {
        out = NTStringValue(
          value.last_change,
          value.server_time,
          value.data.v_string.str.cast<Utf8>().toDartString(
            length: value.data.v_string.len,
          ),
        );
      } else {
        out = NTStringValue(value.last_change, value.server_time, "");
      }
      break;
    case ntTypeRaw:
      var rawArr = value.data.v_raw.data.asTypedList(value.data.v_raw.size);
      out = NTRawValue(value.last_change, value.server_time, List.from(rawArr));
      break;
    case ntTypeBooleanArray:
      var arrPtr = value.data.arr_boolean.arr;
      var newArr = <bool>[];
      for (int i = 0; i < value.data.arr_boolean.size; i++) {
        newArr.add(arrPtr[i] == 1);
      }
      out = NTBooleanArrayValue(value.last_change, value.server_time, newArr);
      break;
    case ntTypeIntegerArray:
      var arr = value.data.arr_int.arr.asTypedList(value.data.arr_int.size);
      out = NTIntegerArrayValue(
        value.last_change,
        value.server_time,
        List.from(arr),
      );
      break;
    case ntTypeFloatArray:
      var arr = value.data.arr_float.arr.asTypedList(value.data.arr_float.size);
      out = NTDoubleArrayValue(
        value.last_change,
        value.server_time,
        List.from(arr),
      );
      break;
    case ntTypeDoubleArray:
      var arr = value.data.arr_double.arr.asTypedList(
        value.data.arr_double.size,
      );
      out = NTDoubleArrayValue(
        value.last_change,
        value.server_time,
        List.from(arr),
      );
      break;
    case ntTypeStringArray:
      var stringArr = value.data.arr_string.arr;
      var newList = <String>[];
      for (int i = 0; i < value.data.arr_string.size; i++) {
        var wpi = stringArr[i];
        newList.add(wpi.str.cast<Utf8>().toDartString(length: wpi.len));
      }
      out = NTStringArrayValue(value.last_change, value.server_time, newList);
      break;

    // Will return an unassigned value if it's either an unassigned value or broken.
    default:
      out = NTUnassignedValue(value.last_change, value.server_time);
      break;
  }

  return out;
}
