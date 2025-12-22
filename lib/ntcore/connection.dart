import 'dart:ffi';

import 'package:flutter/foundation.dart';

class NTInstance {
  final libntcore = switch (defaultTargetPlatform) {
    // only linux and windows are supported.
    TargetPlatform.linux => DynamicLibrary.open("libntcored.so"),
    TargetPlatform.windows => DynamicLibrary.open("ntcored.dll"),

    TargetPlatform.macOS => throw UnimplementedError(),
    TargetPlatform.android => throw UnimplementedError(),
    TargetPlatform.fuchsia => throw UnimplementedError(),
    TargetPlatform.iOS => throw UnimplementedError(),
  };

  NTInstance();
}
