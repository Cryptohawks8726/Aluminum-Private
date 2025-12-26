/// Contains utilities for working with the C abi. Do not import this if you are
/// using the dart bindings.
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

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

// WPI_String type from <wpi/string.h>
final class WPIString extends Struct {
  external Pointer<Utf8> str;

  @Size()
  external int len;
}

Pointer<WPIString> toWpiString(String s) {
  final p = calloc.allocate<WPIString>(sizeOf<WPIString>());
  p.ref.len = s.length;
  p.ref.str = s.toNativeUtf8();

  return p;
}

String wpiToDartString(Pointer<WPIString> wpi) {
  return wpi.ref.str.toDartString(length: wpi.ref.len);
}

/* NT_Value stuff here */
final class NTValue extends Struct {
  @Int()
  external int type; // enum NT_Type
  @Int64()
  external int lastChange;
  @Int64()
  external int serverTime;

  external NTValueInner data;
}

final class NTBooleanArray extends Struct {
  external Pointer<Int> arr;
  @Size()
  external int size;
}

final class NTDoubleArray extends Struct {
  external Pointer<Double> arr;
  @Size()
  external int size;
}

final class NTFloatArray extends Struct {
  external Pointer<Float> arr;
  @Size()
  external int size;
}

final class NTInt64Array extends Struct {
  external Pointer<Int64> arr;
  @Size()
  external int size;
}

final class NTStringArray extends Struct {
  external Pointer<WPIString> arr;
  @Size()
  external int size;
}

final class NTRawData extends Struct {
  external Pointer<Uint8> data;
  @Size()
  external int size;
}

final class NTValueInner extends Union {
  @Int()
  external int vBoolean; // why they decided to reimplement booleans as ints, I have no clue.

  @Int64()
  external int vInt;

  @Float()
  external double vFloat;

  @Double()
  external double vDouble;

  external WPIString vString;

  external NTRawData vRaw;

  external NTBooleanArray arrBoolean;

  external NTDoubleArray arrDouble;

  external NTFloatArray arrFloat;

  external NTInt64Array arrInt;

  external NTStringArray arrString;
}

/* End of NT_Value stuff */

/* NT_Event stuff here */
final class NTEvent extends Struct {
  @UnsignedInt()
  external int listener;

  @UnsignedInt()
  external int flags;

  external NTEventInner data;
}

final class NTEventInner extends Union {
  external NTConnectionInfo connInfo;
  external NTTopicInfo topicInfo;
  external NTValueEventData valueData;
  external NTLogMessage logMessage;
  external NTTimeSyncEventData timeSyncData;
}

final class NTConnectionInfo extends Struct {
  external WPIString remoteId;
  external WPIString remoteIp;
  @UnsignedInt()
  external int remotePort;
  @Uint64()
  external int lastUpdate;
  @UnsignedInt()
  external int protocolVersion;
}

final class NTTopicInfo extends Struct {
  @UnsignedInt()
  external int topicHandle;
  external WPIString topicName;
  @Int()
  external int type;
  external WPIString typeStr;
  external WPIString properties;
}

final class NTValueEventData extends Struct {
  @UnsignedInt()
  external int topic;
  @UnsignedInt()
  external int subentry;
  external NTValue value;
}

final class NTLogMessage extends Struct {
  @UnsignedInt()
  external int level;
  external WPIString filename;
  @UnsignedInt()
  external int line;
  external WPIString message;
}

final class NTTimeSyncEventData extends Struct {
  @Int64()
  external int serverTimeOffset;
  @Int64()
  external int rtt2;
  @Int()
  external int valid; // NT_Bool
}
