import 'dart:ffi';

import 'package:driver_dashboard/ntcore/ntcore_structs.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// A NetworkTables client. Uses the ntcore library from WPILib.
/// See the WPILib C++ docs on ntcore's C api (ntcore_c.h) for
/// more info.
class NTInstance {
  // Uses the right library name depending on platform and debug or release mode.
  final libntcore = switch (defaultTargetPlatform) {
    // only linux and windows are supported.
    // need to use a different path since the file names are different for each platform.
    TargetPlatform.linux => DynamicLibrary.open(
      kDebugMode ? "libntcored.so" : "libntcore.so",
    ),
    TargetPlatform.windows => DynamicLibrary.open(
      kDebugMode ? "ntcored.dll" : "ntcore.dll",
    ),

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
  late final Pointer<WPIString> connectionName;

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
    connectionName = toWpiString(name);
    ntStartClient4(inst, connectionName);
  }

  /// Frees resources in use by this instance. Failing to call this before
  /// the object is destroyed will cause a slight memory leak.
  void dispose() {
    calloc.free(connectionName);
    // doesn't seem to be a way to free instances so I'm guessing the library handles that internally
    // or just only ever has one and doesn't free it or something.
  }
}
