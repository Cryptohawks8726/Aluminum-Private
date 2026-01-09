import 'package:aluminum/ntcore/instance.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:aluminum/util.dart';
import 'package:flutter/material.dart';

class PIDContainer extends StatefulWidget {
  final String title;
  final String subsystemName;
  late final PIDdata pidData;

  PIDContainer({
    required this.subsystemName,
    required this.title,
    super.key,
  }) {
    pidData = PIDdata(subsystemName: subsystemName);
  }

  @override
  State<PIDContainer> createState() => _PIDContainerState();
}

class _PIDContainerState extends State<PIDContainer> {
  // data
  late PID myPID = PID(); // initializes all to 0.0
  late final TextEditingController pcontrol = TextEditingController();
  late final TextEditingController icontrol = TextEditingController();
  late final TextEditingController dcontrol = TextEditingController();
  late final List controllers = <TextEditingController>[
    pcontrol,
    icontrol,
    dcontrol,
  ];

  // TODO: initialize text controllers to have their current PID values
  @override
  void initState() {
    super.initState();
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
        color: appTheme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      constraints: BoxConstraints(maxWidth: 500),
      padding: EdgeInsets.all(30),
      child: Column(
        spacing: 10,
        children: [
          Container(
            alignment: .center,
            child: Text(
              widget.title,
              style: TextStyle(fontSize: 30, fontWeight: .bold),
            ),
          ),

          // wrap PIDTextFields in a listenable builder to get value updates
          ListenableBuilder(
            listenable: widget.pidData.pNotif,
            builder: (context, _) {
            pcontrol.text = widget.pidData.pNotif.currentValue.toString();
            return Column(
              children: [
                PIDTextField(label: "Kp:", controller: pcontrol),
              ],
            );
          }),
          ListenableBuilder(
            listenable: widget.pidData.iNotif,
            builder: (context, _) {
              icontrol.text = widget.pidData.iNotif.currentValue.toString();
              return PIDTextField(label: "Ki:", controller: icontrol);
            },
          ),
          ListenableBuilder(
            listenable: widget.pidData.dNotif,
            builder: (context, _) {
              dcontrol.text = widget.pidData.dNotif.currentValue.toString();
              return PIDTextField(label: "Kd:", controller: dcontrol);
            },
          ),

          FilledButton(
            onPressed: () {
              try {
                myPID.p = double.parse(pcontrol.text);
                myPID.i = double.parse(icontrol.text);
                myPID.d = double.parse(dcontrol.text);
                widget.pidData.setValues(myPID.p, myPID.i, myPID.d);
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
            },
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(appTheme.colorScheme.secondary),
              
            ),
            child: Text("Save", style: TextStyle(color: appTheme.colorScheme.tertiary),),
          ),
        ],
      ),
    );
  }
}
