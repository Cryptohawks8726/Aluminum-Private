import 'package:driver_dashboard/util.dart';
import "package:driver_dashboard/widgets/pid_container.dart";
import 'package:flutter/material.dart';

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
          PIDContainer(title: "Subsystem!!!!!",),
          PIDContainer(title: "Cooler Subsystem B)",),
        ]
      ),
    );
  }
}