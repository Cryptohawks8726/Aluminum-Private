import 'package:driver_dashboard/ntcore/instance.dart';
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

class PIDdata {
  // temporary
  static final NTValueNotifier PIDvalueNotifierp = NTValueNotifier.fromName(
    valueName: "/SmartDashboard/PIDController/p",
    inst: inst,
  );
  static final NTValueNotifier PIDvalueNotifieri = NTValueNotifier.fromName(
    valueName: "/SmartDashboard/PIDController/i",
    inst: inst,
  );
  static NTValueNotifier PIDvalueNotifierd = NTValueNotifier.fromName(
    valueName: "/SmartDashboard/PIDController/d",
    inst: inst,
  );
}
