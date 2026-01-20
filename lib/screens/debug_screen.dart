import 'package:aluminum/util.dart';
import "package:aluminum/widgets/pid_container.dart";
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
      child: Row(
        spacing: 20,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              spacing: 20,
              children: [
                Expanded(
                  child: PIDContainer(
                    subsystemName: "ExampleSubsystem",
                    title: "Subsystem!!!!!",
                  ),
                ),
                Expanded(
                  child: PIDContainer(
                    subsystemName: "ExampleSubsystem",
                    title: "Same Subsystem!!!!!",
                  ),
                ),
              ],
            ),
          ),

          VerticalDivider(),
          Expanded(flex: 1, child: NTTopicDisplay()),
          VerticalDivider(),
          // can be used to display more things in the future
          Expanded(flex: 3, child: const Placeholder()),
        ],
      ),
    );
  }
}
