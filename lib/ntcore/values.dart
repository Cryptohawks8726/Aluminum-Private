// and now we once again are greeted with "oh god there's a c union in my java code help"
// but dart at least has sealed classes so its a little better?
// Doubles and floats have been combined since dart does not have a native 'float' type anyway.

import 'dart:ffi';

/// A class representing a value in NetworkTables, of one of various specific types.
/// This is a sealed class so you can use a switch case to identify the value type.
/// You can also use .toString to get a text representation of the value, whatever type it is.
sealed class NetworkTablesValue {
  final int lastChange;
  final int serverTime;

  const NetworkTablesValue(this.lastChange, this.serverTime);

  @override
  String toString() {
    return "Unknown Value";
  }

  /// returns 0 in normal class
  dynamic getValue() => 0;
}

/// Unassigned NetworkTables value with no data or type.
class NTUnassignedValue extends NetworkTablesValue {
  const NTUnassignedValue(super.lastChange, super.serverTime);
}

/// A boolean in NetworkTables.
class NTBooleanValue extends NetworkTablesValue {
  final bool value;
  const NTBooleanValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value.toString();
  }

  /// returns the value of correct type
  @override
  bool getValue() => value;
}

/// A double (or float) in NetworkTables.
class NTDoubleValue extends NetworkTablesValue {
  final double value;
  const NTDoubleValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value.toString();
  }

  /// returns the value of correct type
  @override
  double getValue() {
    return value;
  }
}

/// A string in NetworkTables.
class NTStringValue extends NetworkTablesValue {
  final String value;
  const NTStringValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value;
  }

  /// returns the value of correct type
  @override
  String getValue() => value;
}

/// Raw data in NetworkTables.
class NTRawValue extends NetworkTablesValue {
  final List<int> value;
  const NTRawValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value.toString();
  }

  /// returns the value of correct type
  @override
  List<int> getValue() => value;
}

/// A boolean array in NetworkTables.
class NTBooleanArrayValue extends NetworkTablesValue {
  final List<bool> value;
  const NTBooleanArrayValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value.toString();
  }

  /// returns the value of correct type
  @override
  List<bool> getValue() => value;
}

/// A double array (or float array) in NetworkTables.
class NTDoubleArrayValue extends NetworkTablesValue {
  final List<double> value;
  const NTDoubleArrayValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value.toString();
  }

  /// returns the value of correct type
  @override
  List<double> getValue() => value;
}

/// A string array in NetworkTables.
class NTStringArrayValue extends NetworkTablesValue {
  final List<String> value;
  const NTStringArrayValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value.toString();
  }

  /// returns the value of correct type
  @override
  List<String> getValue() => value;
}

/// An integer in NetworkTables.
class NTIntegerValue extends NetworkTablesValue {
  final int value;
  const NTIntegerValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value.toString();
  }

  /// returns the value of correct type
  @override
  int getValue() => value;
}

/// An integer array in NetworkTables.
class NTIntegerArrayValue extends NetworkTablesValue {
  final List<int> value;
  const NTIntegerArrayValue(super.lastChange, super.serverTime, this.value);
  @override
  String toString() {
    return value.toString();
  }

  /// returns the value of correct type
  @override
  List<int> getValue() => value;
}
