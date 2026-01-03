import 'package:driver_dashboard/util.dart';
import 'package:flutter/material.dart';


// WIP
// widgets are super unorganized rn

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        spacing: 20,
        children: [
          PIDContainer(),
          PIDContainer(),
        ]
      ),
    );
  }
}


class PIDContainer extends StatefulWidget {
  const PIDContainer({super.key});

  @override
  State<PIDContainer> createState() => _PIDContainerState();
}

class _PIDContainerState extends State<PIDContainer> {

  PID myPID = PID(pval: 0, ival: 0, dval: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      width: 400, height: 300,
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: .center,

            children: [
            Text("Kp:"),
            SizedBox(width: 20,),
            Text(myPID.p.toString()),
            ],
          ),

          Row(
            mainAxisAlignment: .center,

            children: [
              Text("Ki:"),
              SizedBox(width: 20),
              Text(myPID.i.toString()),
            ],
          ),

          Row(
            mainAxisAlignment: .center,
            
            children: [
            Text("Kd:"),
            SizedBox(width: 20,),
            Text(myPID.d.toString()),
            ],
          ),
        ],
      )

    );
  }
}