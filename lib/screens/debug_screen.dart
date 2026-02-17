import 'package:aluminum/ntcore/instance.dart';
import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:aluminum/util.dart';
import "package:aluminum/widgets/pid_container.dart";
import 'package:flutter/material.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

final _subsystemsPath = '/SmartDashboard/Subsystems';
final _subsystemPrefix = NTPrefixNotifier(
  instance: inst,
  prefix: _subsystemsPath,
);

class _DebugScreenState extends State<DebugScreen> {
  String selectedSubsystem = '';

  _DebugScreenState() {
    _subsystemPrefix.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _subsystemPrefix.removeListener(_updateState);
  }

  List<(String, NetworkTablesValue)> _unpackMap(
    String prefix,
    Map<String, dynamic> map,
  ) {
    final out = <(String, NetworkTablesValue)>[];
    for (final entry in map.entries) {
      // filters out hidden nt properties
      if (entry.key.startsWith('.')) {
        continue;
      }
      if (entry.value is Map<String, dynamic>) {
        out.addAll(_unpackMap('$prefix${entry.key}/', entry.value));
      } else if (entry.value is NetworkTablesValue) {
        out.add((prefix + entry.key, entry.value));
      }
    }
    return out;
  }

  // moved out to clean things up
  Widget buildInnerWidget(BuildContext context) {
    final theme = Theme.of(context);
    final subMap = _subsystemPrefix.entries[selectedSubsystem];

    if (subMap == null || subMap is! Map<String, dynamic>) {
      return Center(child: Text('-- select a subsystem --'));
    } else {
      // Build constant and mutable values lists from the submap

      var mutablesList = <(String, NetworkTablesValue)>[];
      var constantsList = <(String, NetworkTablesValue)>[];
      var mutablesMap = subMap['MutableValues'];
      if (mutablesMap != null && mutablesMap is Map<String, dynamic>) {
        mutablesList = _unpackMap('', mutablesMap);
        constantsList = _unpackMap(
          '',
          Map.fromEntries(
            subMap.entries.where((entry) => entry.key != 'MutableValues'),
          ),
        );
      } else {
        constantsList = _unpackMap('', subMap);
      }
      return Center(
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
                child: Column(
                  children: [
                    Text(
                      'Mutable Values',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (child, idx) {
                          final entry = mutablesList[idx];
                          return Text('${entry.$1} = ${entry.$2.toString()}');
                        },
                        itemCount: mutablesList.length,
                      ),
                    ),
                  ],
                ),
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
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (child, idx) {
                          final entry = constantsList[idx];
                          return Text('${entry.$1} = ${entry.$2.toString()}');
                        },
                        itemCount: constantsList.length,
                      ),
                    ),
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
    if (_subsystemPrefix.entries.keys.isEmpty) {
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
            segments: _subsystemPrefix.entries.keys
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
