import 'dart:ffi';

import 'package:driver_dashboard/ntcore/ntcore_structs.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef NTListenerCallback = Void Function(Pointer<Void>, Pointer<NTEvent>);

String _formatLibName(String name) {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      // TODO: Handle this case.
      throw UnimplementedError();
    case TargetPlatform.fuchsia:
      // TODO: Handle this case.
      throw UnimplementedError();
    case TargetPlatform.iOS:
      // TODO: Handle this case.
      throw UnimplementedError();
    case TargetPlatform.linux:
      return 'lib$name.so';
    case TargetPlatform.macOS:
      return 'lib$name.dylib';
    case TargetPlatform.windows:
      return '$name.dll';
  }
}

DynamicLibrary _findNTCoreLib() {
  try {
    return DynamicLibrary.open(
      kDebugMode ? _formatLibName("ntcored") : _formatLibName("ntcore"),
    );
  } catch (_) {
    return DynamicLibrary.open(_formatLibName('ntcoreffi'));
  }
}

/// Class containing ffi bindings to all C functions used by the dashboard.
final class NTCoreABI {
  // Uses the right library name depending on platform and debug or release mode.
  static final _libntcore = _findNTCoreLib();

  // Creates an instance when the class is instantiated.
  static final ntCreateInstance = _libntcore
      .lookupFunction<UnsignedInt Function(), int Function()>(
        "NT_CreateInstance",
      );

  // C functions used by the class. This is the entirety of the ABI bindings.
  // Names beginning with '_' are private to this library -
  // almost everything here is private to prevent directly interfacing with the ABI.
  /// void NT_StartClient4(NT_Inst inst, const struct WPI_String *identity)
  static final ntStartClient4 = _libntcore
      .lookupFunction<
        Void Function(UnsignedInt, Pointer<WPIString>),
        void Function(int, Pointer<WPIString>)
      >("NT_StartClient4");

  /// void NT_SetServerTeam(NT_Inst inst, unsigned int team, unsigned int port)
  static final ntSetServerTeam = _libntcore
      .lookupFunction<
        Void Function(UnsignedInt, UnsignedInt, UnsignedInt),
        void Function(int, int, int)
      >("NT_SetServerTeam");

  /// void NT_SetServer(NT_Inst isnt, const struct WPI_String *server_name, unsigned int port)
  static final ntSetServer = _libntcore
      .lookupFunction<
        Void Function(UnsignedInt, Pointer<WPIString>, UnsignedInt),
        void Function(int, Pointer<WPIString>, int)
      >("NT_SetServer");

  /// NT_Entry NT_GetEntry(NT_Inst inst, const struct WPI_String *name)
  static final ntGetEntry = _libntcore
      .lookupFunction<
        UnsignedInt Function(UnsignedInt, Pointer<WPIString>),
        int Function(int, Pointer<WPIString>)
      >("NT_GetEntry");

  /// void NT_GetEntryName(NT_Entry entry, struct WPI_String *name)
  static final ntGetEntryName = _libntcore
      .lookupFunction<
        Void Function(UnsignedInt, Pointer<WPIString>),
        void Function(int, Pointer<WPIString>)
      >("NT_GetEntryName");

  /// void NT_DestroyInstance(NT_Inst inst)
  static final ntDestroyInstance = _libntcore
      .lookupFunction<Void Function(UnsignedInt), void Function(int)>(
        "NT_DestroyInstance",
      );

  /// void NT_GetEntryValue(NT_Entry entry, struct NT_Value *value)
  static final ntGetEntryValue = _libntcore
      .lookupFunction<
        Void Function(UnsignedInt, Pointer<NTValue>),
        void Function(int, Pointer<NTValue>)
      >("NT_GetEntryValue");

  /// NT_Bool NT_SetEntryValue(NT_Entry entry, const struct NT_Value *value)
  static final ntSetEntryValue = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Pointer<NTValue>),
        int Function(int, Pointer<NTValue>)
      >("NT_SetEntryValue");

  // idk if this will be useful or not I figured just in case
  /// int64_t NT_Now()
  static final ntNow = _libntcore
      .lookupFunction<Int64 Function(), int Function()>("NT_Now");

  /// enum NT_Type NT_GetValueType(const struct NT_Value *value)
  static final ntGetValueType = _libntcore
      .lookupFunction<
        Int Function(Pointer<NTValue>),
        int Function(Pointer<NTValue>)
      >("NT_GetValueType");

  /* Functions for getting inner data out of an NT_Value. I mean I'm pretty sure you could do this
   yourself but whatever fine. Note that the return values are whether or not the operation was successful.
   Unless it returns a pointer - then I assume that pointer may be null. */
  static final ntGetValueBoolean = _libntcore
      .lookupFunction<
        Int Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Int>),
        int Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Int>)
      >("NT_GetValueBoolean");
  static final ntGetValueInteger = _libntcore
      .lookupFunction<
        Int Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Int64>),
        int Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Int64>)
      >("NT_GetValueInteger");
  static final ntGetValueFloat = _libntcore
      .lookupFunction<
        Int Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Float>),
        int Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Float>)
      >("NT_GetValueFloat");
  static final ntGetValueDouble = _libntcore
      .lookupFunction<
        Int Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Double>),
        int Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Double>)
      >("NT_GetValueDouble");
  static final ntGetValueString = _libntcore
      .lookupFunction<
        Pointer<Utf8> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        ),
        Pointer<Utf8> Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Size>)
      >("NT_GetValueString");
  static final ntGetValueRaw = _libntcore
      .lookupFunction<
        Pointer<Uint8> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        ),
        Pointer<Uint8> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        )
      >("NT_GetValueRaw");
  static final ntGetValueBooleanArray = _libntcore
      .lookupFunction<
        Pointer<Int> Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Size>),
        Pointer<Int> Function(Pointer<NTValue>, Pointer<Uint64>, Pointer<Size>)
      >("NT_GetValueBooleanArray");
  static final ntGetValueIntegerArray = _libntcore
      .lookupFunction<
        Pointer<Int64> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        ),
        Pointer<Int64> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        )
      >("NT_GetValueIntegerArray");
  static final ntGetValueFloatArray = _libntcore
      .lookupFunction<
        Pointer<Float> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        ),
        Pointer<Float> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        )
      >("NT_GetValueFloatArray");
  static final ntGetValueDoubleArray = _libntcore
      .lookupFunction<
        Pointer<Double> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        ),
        Pointer<Double> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        )
      >("NT_GetValueDoubleArray");
  static final ntGetValueStringArray = _libntcore
      .lookupFunction<
        Pointer<WPIString> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        ),
        Pointer<WPIString> Function(
          Pointer<NTValue>,
          Pointer<Uint64>,
          Pointer<Size>,
        )
      >("NT_GetValueStringArray");
  /* End of value getting functions */

  /* Value setting functions to push values to NT (these ones are actually in ntcore_c_types.h)
   Passing 0 as the current time will just use current NT time. All of these are basically just
   the entry handle, timestamp, and then the actual data to publish. */
  static final ntSetBoolean = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Int),
        int Function(int, int, int)
      >("NT_SetBoolean");
  static final ntSetInteger = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Int64),
        int Function(int, int, int)
      >("NT_SetInteger");
  static final ntSetFloat = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Float),
        int Function(int, int, double)
      >("NT_SetFloat");
  static final ntSetDouble = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Double),
        int Function(int, int, double)
      >("NT_SetDouble");
  static final ntSetString = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Pointer<WPIString>),
        int Function(int, int, Pointer<WPIString>)
      >("NT_SetString");
  static final ntSetRaw = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Pointer<Utf8>, Size),
        int Function(int, int, Pointer<Utf8>, int)
      >("NT_SetRaw");
  static final ntSetBooleanArray = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Pointer<Int>, Size),
        int Function(int, int, Pointer<Int>, int)
      >("NT_SetBooleanArray");
  static final ntSetIntegerArray = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Pointer<Int64>, Size),
        int Function(int, int, Pointer<Int64>, int)
      >("NT_SetIntegerArray");
  static final ntSetFloatArray = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Pointer<Float>, Size),
        int Function(int, int, Pointer<Float>, int)
      >("NT_SetFloatArray");
  static final ntSetDoubleArray = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Pointer<Double>, Size),
        int Function(int, int, Pointer<Double>, int)
      >("NT_SetDoubleArray");
  static final ntSetStringArray = _libntcore
      .lookupFunction<
        Int Function(UnsignedInt, Int64, Pointer<WPIString>, Size),
        int Function(int, int, Pointer<WPIString>, int)
      >("NT_SetStringArray");
  /* End of value setting functions */

  // Could maybe add the getters as well in the future, although usually it
  // makes more sense to use the NT_Value struct.

  /* Cleanup functions - call these when you are done using structs!
     The dispose functions do not free memory - they only free things INSIDE the struct. */
  static final ntDisposeValue = _libntcore
      .lookupFunction<
        Void Function(Pointer<NTValue>),
        void Function(Pointer<NTValue>)
      >("NT_DisposeValue");

  static final ntFreeCharArray = _libntcore
      .lookupFunction<
        Void Function(Pointer<Utf8>),
        void Function(Pointer<Utf8>)
      >("NT_FreeCharArray");
  static final ntFreeBooleanArray = _libntcore
      .lookupFunction<Void Function(Pointer<Int>), void Function(Pointer<Int>)>(
        "NT_FreeBooleanArray",
      );
  static final ntFreeIntegerArray = _libntcore
      .lookupFunction<
        Void Function(Pointer<Int64>),
        void Function(Pointer<Int64>)
      >("NT_FreeIntegerArray");
  static final ntReleaseEntry = _libntcore
      .lookupFunction<Void Function(UnsignedInt), void Function(int)>(
        "NT_ReleaseHandle",
      );
  static final ntDisposeEvent = _libntcore
      .lookupFunction<
        Void Function(Pointer<NTEvent>),
        void Function(Pointer<NTEvent>)
      >("NT_DisposeEvent");
  static final ntDisposeEventArray = _libntcore
      .lookupFunction<
        Void Function(Pointer<NTEvent>, Size),
        void Function(Pointer<NTEvent>, int)
      >("NT_DisposeEventArray");

  /// NT_Listener NT_AddListener(NT_Handle handle, unsigned int mask, void *data, NT_ListenerCallback callback)
  /// DO NOT USE THIS unless you can figure out how to run a sync callback
  static final ntAddListener = _libntcore
      .lookupFunction<
        UnsignedInt Function(
          UnsignedInt,
          UnsignedInt,
          Pointer<Void>,
          Pointer<NativeFunction<NTListenerCallback>>,
        ),
        int Function(
          int,
          int,
          Pointer<Void>,
          Pointer<NativeFunction<NTListenerCallback>>,
        )
      >("NT_AddListener");

  /// void NT_GetTopicName(NT_Topic topic, struct WPI_String *name)
  static final ntGetTopicName = _libntcore
      .lookupFunction<
        Void Function(UnsignedInt, Pointer<WPIString>),
        void Function(int, Pointer<WPIString>)
      >("NT_GetTopicName");

  /// NT_ListenerPoller NT_CreateListenerPoller(NT_Inst inst)
  static final ntCreateListenerPoller = _libntcore
      .lookupFunction<UnsignedInt Function(UnsignedInt), int Function(int)>(
        "NT_CreateListenerPoller",
      );

  /// struct NT_Event * NT_ReadListenerQueue(NT_ListenerPoller poller, size_t *len)
  static final ntReadListenerQueue = _libntcore
      .lookupFunction<
        Pointer<NTEvent> Function(UnsignedInt, Pointer<Size>),
        Pointer<NTEvent> Function(int, Pointer<Size>)
      >("NT_ReadListenerQueue");

  /// NT_Listener NT_AddPolledListener(NT_ListenerPoller poller, NT_Handle handle, unsigned int mask)
  static final ntAddPolledListener = _libntcore
      .lookupFunction<
        UnsignedInt Function(UnsignedInt, UnsignedInt, UnsignedInt),
        int Function(int, int, int)
      >("NT_AddPolledListener");

  /// void NT_RemoveListener(NT_Listener listener)
  static final ntRemoveListener = _libntcore
      .lookupFunction<Void Function(UnsignedInt), void Function(int)>(
        "NT_RemoveListener",
      );

  /// void NT_DestroyListenerPoller(NT_ListenerPoller poller)
  static final ntDestroyListenerPoller = _libntcore
      .lookupFunction<Void Function(UnsignedInt), void Function(int)>(
        "NT_DestroyListenerPoller",
      );

  // I literally went and checked the source code and all NT_InitValue does is
  // void NT_InitValue(NT_Value* value) {
  //   value->type = NT_UNASSIGNED;
  //   value->last_change = 0;
  //   value->server_time = 0;
  // }
  // So I won't even bother using it.
}
