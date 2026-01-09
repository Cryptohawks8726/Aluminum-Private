import 'package:aluminum/ntcore/instance.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:aluminum/settings.dart';
import 'package:flutter/material.dart';

// GENERAL //
final List<String?> llCamUrls = Settings.getCameraURLs;

String formatTime({required int timeInSeconds}) {
  return "${(timeInSeconds / 60).round()}:${timeInSeconds % 60}";
}

// may or may not be used idk yet - ismail
class PID {
  double pval = 0, ival = 0, dval = 0;
  // contructor for initializing with values
  PID.setValues({required this.pval, required this.ival, required this.dval});
  PID();

  double get p => pval;
  double get i => ival;
  double get d => dval;
  set p(double p) => pval = p;
  set i(double i) => ival = i;
  set d(double d) => dval = d;
}

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    // Various colors I stole from the team colors, and also blue and red
    // dark blue
    primary: Color.fromARGB(0xFF, 0x0B, 0x35, 0x62),
    secondary: Colors.white,
    tertiary: Color.fromARGB(0xFF, 0x04, 0x00, 0x3b),
    // team navy
    seedColor: Color.fromARGB(0xFF, 0x04, 0x00, 0x3b),
    // a rebuilt color - reddish
    // seedColor: Color.fromARGB(0xFF, 0xea, 0x57, 0x2e),
    // seedColor: Colors.blue,
    // seedColor: Colors.red,

    // seedColor: Colors.indigo,
    brightness: .dark,
  ),

  textTheme: TextTheme(),
);

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

class PIDTextField extends StatelessWidget {
  final String label;

  final TextEditingController controller;

  const PIDTextField({
    required this.label,

    required this.controller,

    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,

      children: [
        Text(label, style: TextStyle(fontSize: 20, fontWeight: .bold)),

        SizedBox(width: 20),

        Expanded(flex: 1, child: TextField(controller: controller)),
      ],
    );
  }
}

class NTTopicData {
  bool isExpanded = false;
  final NTValueNotifier notifier;
  final String title;

  NTTopicData({required this.notifier, required this.title});
}

class NTTopicDisplay extends StatelessWidget {
  NTTopicDisplay({super.key});

  final TextStyle style = TextStyle(fontSize: 15);

  // fill up this section with any listeners you want to see
  final List<NTTopicData> topics = <NTTopicData>[
    NTTopicData(notifier: gameTimeNotifier, title: "gameTime"),
    NTTopicData(notifier: stateNotifier, title: "currentState"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(
            "NetworkTables:",
            style: TextStyle(fontSize: 25, fontWeight: .bold),
          ),
        ),
        Divider(),
        for (NTTopicData c in topics)
          ListenableBuilder(
            listenable: c.notifier,
            builder: (context, _) {
              var s = c.notifier.currentValue.toString();
              return Text("${c.title}: $s", style: style);
            },
          ),
      ],
    );
  }
}
