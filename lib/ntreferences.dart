import 'package:aluminum/ntcore/instance.dart';
import 'package:flutter/foundation.dart';

/*
update port number and server name for irl testing
localhost:5810 can be used for testing w/ robot sim (unless you're on mac ;-;)
TODO: Add toggleable option in dashboard for this
*/
final NTInstance inst = kDebugMode
    // Connects to localhost in debug mode by default, and in release builds connects to the team by default
    ? (NTInstance()..updateServerNamePort("localhost", 5810))
    : NTInstance();

final NTValueNotifier gameTimeNotifier = NTValueNotifier.fromName(
  valueName: "/SmartDashboard/gameTime",
  inst: inst,
);
final NTValueNotifier stateNotifier = NTValueNotifier.fromName(
  valueName: "/SmartDashboard/currentState",
  inst: inst,
);
final robotPosNotifier = NTValueNotifier.fromName(
  valueName: '/SmartDashboard/robot2DPosition',
  inst: inst,
);
final matchNumberNotifier = NTValueNotifier.fromName(
  valueName: '/FMSInfo/MatchNumber',
  inst: inst,
);
final isRedAllianceNotifier = NTValueNotifier.fromName(
  valueName: '/FMSInfo/IsRedAlliance',
  inst: inst,
);
final autoChooserSelectedPath = '/SmartDashboard/autoChooser/active';
final autoChooserOptionsNotifier = NTValueNotifier.fromName(
  valueName: '/SmartDashboard/autoChooser/options',
  inst: inst,
);
final autoChooserSelectedNotifier = NTValueNotifier.fromName(
  valueName: autoChooserSelectedPath,
  inst: inst,
);

/// A class used to get mutable PID data from a subsystem
class PIDdata {
  late final String sdPath;
  late final NTValueNotifier pNotif;
  late final NTValueNotifier iNotif;
  late final NTValueNotifier dNotif;

  /// This constructor will only work if values are under a MutableValues subtable
  PIDdata({required String subsystemName}) {
    sdPath = "/SmartDashboard/Subsystems/$subsystemName/MutableValues";
    pNotif = NTValueNotifier.fromName(valueName: "$sdPath/kP", inst: inst);
    iNotif = NTValueNotifier.fromName(valueName: "$sdPath/kI", inst: inst);
    dNotif = NTValueNotifier.fromName(valueName: "$sdPath/kD", inst: inst);
  }

  /// updates PID values in NetworkTables
  void setValues(double kp, double ki, double kd) {
    inst.setEntryDouble("$sdPath/kP", kp);
    inst.setEntryDouble("$sdPath/kI", ki);
    inst.setEntryDouble("$sdPath/kD", kd);
  }
}
