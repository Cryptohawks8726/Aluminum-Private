import 'package:flutter/material.dart';

// GENERAL //
const List<String?> llCamUrls = [null, null];

String formatTime({required int timeInSeconds}) {
  return "${(timeInSeconds / 60).round()}:${timeInSeconds % 60}";
}

// may or may not be used idk yet - ismail
class PID {
  double pval, ival, dval;

  PID({required this.pval, required this.ival, required this.dval});

  double get p => pval; double get i => ival; double get d => dval;
  set p(double p) => pval = p;
  set i(double i) => ival = i;
  set d(double d) => dval = d;
}

// LAYOUT WIDGETS //

// widget to be displayed when camera can't connect
Widget Function(BuildContext)? cameraErrorWidget = (context) => Container(
  color: Colors.black,
  // width: 640,
  // height: 480,
  padding: const EdgeInsets.all(10),
  child: Center(
    child: const Text(
      "No Connection!",
      style: TextStyle(color: Colors.white, fontSize: 20),
    ),
  ),
);

class LabelContainer extends StatelessWidget {
  final String label;
  final String data;

  const LabelContainer({required this.label, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      width: 200,
      height: 200,
      alignment: .center,
      padding: EdgeInsets.fromLTRB(5, 30, 5, 30),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(fontSize: 25, fontWeight: .bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(alignment: .center, child: Text(data)),
          ),
        ],
      ),
    );
  }
}
