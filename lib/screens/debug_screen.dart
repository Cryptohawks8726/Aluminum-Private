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

final subsystemPrefix = NTPrefixNotifier(
  instance: inst,
  prefix: '/SmartDashboard/Subsystems',
);

class _DebugScreenState extends State<DebugScreen> {
  String selectedSubsystem = '';

  _DebugScreenState() {
    subsystemPrefix.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    subsystemPrefix.removeListener(_updateState);
  }

  // moved out to clean things up
  Widget buildInnerWidget(BuildContext context) {
    final theme = Theme.of(context);
    final subMap = subsystemPrefix.entries[selectedSubsystem];

    if (subMap == null || subMap is! Map<String, dynamic>) {
      return Center(child: Text('-- select a subsystem --'));
    } else {
      // Build constant and mutable values lists from the submap
      final constantsList = <String>[];
      final mutablesList = <String>[];

      return Center(
        // child: Column(
        //   children: [
        //     Text('Debug panel is currently under construction...'),
        //     Text('For now, you can view and set values through glass.'),
        //   ],
        // ),
        child: Row(
          spacing: 12.0,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(10.0),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      'Constant Values',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      // return Row(
      //   spacing: 20,
      //   children: [
      //     Expanded(
      //       flex: 2,
      //       child: Column(
      //         spacing: 20,
      //         children: [
      //           Expanded(
      //             child: PIDContainer(
      //               subsystemName: "ExampleSubsystem",
      //               title: "Subsystem!!!!!",
      //             ),
      //           ),
      //           Expanded(
      //             child: PIDContainer(
      //               subsystemName: "ExampleSubsystem",
      //               title: "Same Subsystem!!!!!",
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),

      //     VerticalDivider(),
      //     Expanded(flex: 1, child: NTTopicDisplay()),
      //     VerticalDivider(),
      //     // can be used to display more things in the future
      //     Expanded(flex: 3, child: const Placeholder()),
      //   ],
      // );
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
