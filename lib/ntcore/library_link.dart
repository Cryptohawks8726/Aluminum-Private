import 'dart:ffi';

import 'package:aluminum/ntcore/ntcore.g.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

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
    return DynamicLibrary.open(_formatLibName("ntcoreffi"));
  } catch (_) {
    return DynamicLibrary.open(_formatLibName('ntcore'));
  }
}

final ntcore = NTCoreLibrary(_findNTCoreLib());

// util functions
Pointer<WPI_String> toWpiString(String s) {
  final p = calloc.allocate<WPI_String>(sizeOf<WPI_String>());
  p.ref.len = s.length;
  p.ref.str = s.toNativeUtf8().cast();

  return p;
}

String wpiToDartString(Pointer<WPI_String> wpi) {
  return wpi.ref.str.cast<Utf8>().toDartString(length: wpi.ref.len);
}
