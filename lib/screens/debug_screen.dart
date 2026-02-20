import 'package:aluminum/ntcore/instance.dart';
import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
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
  var mutableTextControllers = <TextEditingController>[];
  var mutableTextFocusNodes = <FocusNode>[];

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
      final mutableTableRows = <TableRow>[];
      for (int i = 0; i < mutablesList.length; i++) {
        final e = mutablesList[i];
        mutableTableRows.add(
          TableRow(
            decoration: BoxDecoration(
              color: i % 2 == 0
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer,
            ),
            children: [
              Text(e.$1),
              Text('Currently: ${e.$2}'),
              Text('Set: '),
              TextField(
                selectAllOnFocus: false,
                onSubmitted: (s) {
                  tryParseAndSetValue(
                    oldValue: e.$2,
                    string: s,
                    path:
                        '$_subsystemsPath/$selectedSubsystem/MutableValues/${e.$1}',
                  );
                },
              ),
            ],
          ),
        );
      }
      final constTableRows = <TableRow>[];
      for (int i = 0; i < constantsList.length; i++) {
        final e = constantsList[i];
        constTableRows.add(
          TableRow(
            decoration: BoxDecoration(
              color: i % 2 == 0
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer,
            ),
            children: [Text(e.$1), Text(e.$2.toString())],
          ),
        );
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
                    Expanded(
                      child: ListView(
                        children: [
                          Table(
                            columnWidths: {
                              0: FractionColumnWidth(0.5),
                              1: FractionColumnWidth(0.2),
                              2: FractionColumnWidth(0.1),
                              3: FractionColumnWidth(0.2),
                            },
                            children: mutableTableRows,
                          ),
                        ],
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
                    Expanded(
                      child: ListView(
                        children: [
                          Table(
                            columnWidths: {
                              0: FractionColumnWidth(0.8),
                              1: FractionColumnWidth(0.2),
                            },
                            children: constTableRows,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
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

/// Util function to set a value appropriately.
/// Returns true if the string was successfully parsed and the value was set.
bool tryParseAndSetValue({
  required NetworkTablesValue oldValue,
  required String string,
  required String path,
}) {
  switch (oldValue) {
    case NTUnassignedValue():
      return false;
    case NTBooleanValue():
      inst.setEntryBool(path, string.toLowerCase().characters.first == 't');
      return true;
    case NTDoubleValue():
      final d = double.tryParse(string);
      if (d != null) {
        inst.setEntryDouble(path, d);
        return true;
      } else {
        return false;
      }
    case NTStringValue():
      inst.setEntryString(path, string);
      return true;

    case NTDoubleArrayValue():
      var editedString = string;
      if (string.characters.first == '[' || string.characters.first == '{') {
        editedString = string.substring(1, string.length - 1);
      }
      final fragments = editedString.split(',');
      final list = <double>[];
      for (final f in fragments) {
        final d = double.tryParse(f);
        if (d == null) {
          return false;
        } else {
          list.add(d);
        }
      }
      inst.setEntryDoubleArray(path, list);
      return true;

    // BELOW ARE ALL UNIMPLEMENTED!!!!
    // case NTRawValue():
    //   // TODO: Handle this case.
    //   throw UnimplementedError();
    // case NTBooleanArrayValue():
    //   // TODO: Handle this case.
    //   throw UnimplementedError();

    // case NTStringArrayValue():
    //   // TODO: Handle this case.
    //   throw UnimplementedError();
    // case NTIntegerValue():
    //   // TODO: Handle this case.
    //   throw UnimplementedError();
    // case NTIntegerArrayValue():
    //   // TODO: Handle this case.
    //   throw UnimplementedError();
    default:
      return false;
  }
}
