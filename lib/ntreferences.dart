import 'package:driver_dashboard/ntcore/instance.dart';

/*
update port number and server name for irl testing
localhost:5810 can be used for testing w/ robot sim (unless you're on mac ;-;)
TODO: Add toggleable option in dashboard for this
  */
final NTInstance inst = NTInstance()..updateServerNamePort("localhost", 5810);

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
