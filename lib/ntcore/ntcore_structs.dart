import 'dart:ffi';

import 'package:ffi/ffi.dart';

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
