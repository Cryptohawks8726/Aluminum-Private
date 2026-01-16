import 'package:aluminum/ntcore/instance.dart';
import 'package:aluminum/util.dart';
import 'package:flutter/foundation.dart';

/*
update port number and server name for irl testing
localhost:5810 can be used for testing w/ robot sim
*/
final NTInstance inst = kDebugMode
    ? (NTInstance()..updateServerNamePort("localhost", 5810))
    : NTInstance();

// --- CONSTANTS ---
// Define the path here so we can use it in field_view.dart too
const String waypointsPath = '/SmartDashboard/setpoints';

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

// Notifier for the custom waypoints list
final NTValueNotifier waypointsEntry = NTValueNotifier.fromName(
  valueName: waypointsPath,
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

class PIDdata {
  late final String sdPath;
  late final NTValueNotifier pNotif;
  late final NTValueNotifier iNotif;
  late final NTValueNotifier dNotif;

  PIDdata({required String subsystemName}) {
    sdPath = "/SmartDashboard/Subsystems/$subsystemName/MutableValues";
    pNotif = NTValueNotifier.fromName(valueName: "$sdPath/kP", inst: inst);
    iNotif = NTValueNotifier.fromName(valueName: "$sdPath/kI", inst: inst);
    dNotif = NTValueNotifier.fromName(valueName: "$sdPath/kD", inst: inst);
  }

  void setValues(double kp, double ki, double kd) {
    inst.setEntryDouble("$sdPath/kP", kp);
    inst.setEntryDouble("$sdPath/kI", ki);
    inst.setEntryDouble("$sdPath/kD", kd);
  }
}
