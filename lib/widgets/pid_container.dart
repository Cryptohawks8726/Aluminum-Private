import 'package:driver_dashboard/util.dart';
import 'package:flutter/material.dart';

class PIDContainer extends StatefulWidget {
  final String title;

  const PIDContainer({required this.title, super.key});

  @override
  State<PIDContainer> createState() => _PIDContainerState();
}

class _PIDContainerState extends State<PIDContainer> {
  // data
  // TODO: initialize PID object to have correct values from nt
  PID myPID = PID(); // initializes all to 0.0
  final TextEditingController pcontrol = TextEditingController();
  final TextEditingController icontrol = TextEditingController();
  final TextEditingController dcontrol = TextEditingController();
  late final List controllers = <TextEditingController>[
    pcontrol,
    icontrol,
    dcontrol,
  ];

  String valueText = "";

  void refreshText() => setState(() {
    valueText = "Current PID Values: ${myPID.p}, ${myPID.i}, ${myPID.d}";
  });
  // controller's text will initially be at zero for now
  // TODO: initialize text controllers to have their current PID values
  @override
  void initState() {
    super.initState();
    for (TextEditingController c in controllers) {
      c.text = "0.0";
    }
    refreshText();
  }
  // dispose controllers to free up memory
  @override
  void dispose() {
    super.dispose();
    for (TextEditingController c in controllers) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      width: 400,
      height: 350,
      padding: EdgeInsets.all(30),
      child: Column(
        spacing: 10,
        children: [
          Container(
            alignment: .center,
            child: Text(widget.title, style: TextStyle(fontSize: 30, fontWeight: .bold),),
          ),

          PIDTextField(label: "Kp:", controller: pcontrol),
          PIDTextField(label: "Ki:", controller: icontrol),
          PIDTextField(label: "Kd:", controller: dcontrol),
          // show current values
          Text(valueText),

          FilledButton(
            onPressed: () {
              try {
                myPID.p = double.parse(pcontrol.text);
                myPID.i = double.parse(icontrol.text);
                myPID.d = double.parse(dcontrol.text);
                // TODO: send through network tables
              } on FormatException {
                // when values are not doubles
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Formatting Error:"),
                    content: const Text(
                      "One or more of the inputed values cannot be converted to a double.\nCheck if there has been a typo in one of the fields.",
                    ),
                  ),
                );
              }
              refreshText();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
