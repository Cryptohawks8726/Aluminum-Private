import 'dart:ffi';

import 'package:driver_dashboard/ntcore/ntcore_structs.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// A NetworkTables client. Uses the ntcore library from WPILib.
/// See the WPILib C++ docs on ntcore's C api (ntcore_c.h) for
/// more info.
class NTInstance {
  final libntcore = switch (defaultTargetPlatform) {
    // only linux and windows are supported.
    // need to use a different path since the file names are different for each platform.
    TargetPlatform.linux => DynamicLibrary.open("libntcored.so"),
    TargetPlatform.windows => DynamicLibrary.open("ntcored.dll"),

    TargetPlatform.macOS => throw UnimplementedError(),
    TargetPlatform.android => throw UnimplementedError(),
    TargetPlatform.fuchsia => throw UnimplementedError(),
    TargetPlatform.iOS => throw UnimplementedError(),
  };

  // Slew of late final variables to set up the client and
  // lookup all of the C abi functions needed.

  // Creates an instance when the class is instantiated.
  late final ntCreateInstance = libntcore
      .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
        "NT_CreateInstance",
      );
  late final Pointer<Void> inst = ntCreateInstance();

  // C functions used by the class.
  // void NT_StartClient4(NT_Inst inst, const struct WPI_String *identity)
  late final ntStartClient4 = libntcore
      .lookupFunction<
        Void Function(Pointer<Void>, Pointer<WPIString>),
        void Function(Pointer<Void>, Pointer<WPIString>)
      >("NT_StartClient4");

  /// Creates a new instance connected to the specific team number and port.
  NTInstance({
    int teamNumber = 8726,
    int port = 5810,
    name = "8726DriverDashboard",
  }) {
    ntStartClient4(inst, toWpiString(name));
  }
}
