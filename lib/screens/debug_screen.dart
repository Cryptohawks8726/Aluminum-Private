import 'package:aluminum/ntcore/instance.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:aluminum/util.dart';
import "package:aluminum/widgets/pid_container.dart";
import 'package:flutter/material.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final subsystemPrefix = NTPrefixNotifier(
    instance: inst,
    prefix: '/SmartDashboard/Subsystems',
  );
  String selectedSubsystem = '';

  _DebugScreenState() {
    subsystemPrefix.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    subsystemPrefix.dispose();
    super.dispose();
  }

  // moved out to clean things up
  Widget buildInnerWidget(BuildContext context) {
    final subMap = subsystemPrefix.entries[selectedSubsystem];
    if (subMap == null) {
      return Center(child: Text('-- select a subsystem --'));
    } else {
      return Row(
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (subsystemPrefix.entries.keys.isEmpty) {
      return Center(child: Text('No subsystems found.'));
    }
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: .max,
        children: [
          // Button for choosing a subsystem.
          SegmentedButton<String>(
            segments: subsystemPrefix.entries.keys
                .map((String s) {
                  return ButtonSegment<String>(value: s, label: Text(s));
                })
                .toList(growable: false),
            selected: <String>{selectedSubsystem},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                selectedSubsystem = newSelection.first;
              });
            },
            showSelectedIcon: false,
          ),
          const Divider(),
          Expanded(child: buildInnerWidget(context)),
        ],
      ),
    );
  }
}
