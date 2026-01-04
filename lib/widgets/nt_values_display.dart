import 'package:driver_dashboard/ntcore/instance.dart';
import 'package:driver_dashboard/ntcore/values.dart';
import 'package:driver_dashboard/ntreferences.dart';
import 'package:flutter/material.dart';
import 'package:stretch_wrap/stretch_wrap.dart';

/// Places all its child widgets in a stretched layout
/// so they fill the given space.
class NTValuesDisplay extends StatefulWidget {
  final List<Widget> children;
  const NTValuesDisplay({super.key, required this.children});

  @override
  State<StatefulWidget> createState() => _NTValuesDisplayState();
}

class _NTValuesDisplayState extends State<NTValuesDisplay> {
  @override
  Widget build(BuildContext context) {
    return StretchWrap(
      spacing: 4.0,
      runSpacing: 4.0,
      crossRunAlignment: .stretch,
      children: widget.children
          .map((Widget w) {
            if (w is Stretch) {
              return w;
            } else {
              return Stretch(child: w);
            }
          })
          .toList(growable: false),
      // children: [
      // placeholder lunite counter example
      //   Stretch(
      //   ),
      //   // true/false value example
      //   Stretch(
      //   ),
      //   // number example
      //   Stretch(
      //     child: Container(
      //       padding: EdgeInsets.all(5.0),
      //       decoration: BoxDecoration(
      //         color: theme.colorScheme.inversePrimary,
      //         borderRadius: BorderRadius.all(Radius.circular(15.0)),
      //       ),
      //       child: Column(
      //         mainAxisAlignment: .center,
      //         children: [Text('Some Number:'), Text('129.56')],
      //       ),
      //     ),
      //   ),
      //   // long widget example
      //   Stretch(
      //     child: Container(
      //       padding: EdgeInsets.all(5.0),
      //       decoration: BoxDecoration(
      //         color: theme.colorScheme.secondaryContainer,
      //         borderRadius: BorderRadius.all(Radius.circular(15.0)),
      //       ),
      //       child: Column(
      //         mainAxisAlignment: .center,
      //         children: [
      //           Text('Super Long String Value:'),
      //           Text('Woah This is A Really Long String from the Robot'),
      //         ],
      //       ),
      //     ),
      //   ),
      // ],
    );
  }
}

// Some sample widget classes to use for displaying common types of info

/// A widget to display a true/false value in networktables.
class BooleanDisplayTile extends StatelessWidget {
  late final String displayText;
  late final NTValueNotifier notifier;
  BooleanDisplayTile({
    required String valueName,
    String? displayText,
    super.key,
  }) {
    notifier = NTValueNotifier.fromName(valueName: valueName, inst: inst);
    this.displayText = displayText ?? valueName;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, child) {
        bool? b = switch (notifier.currentValue) {
          NTBooleanValue(:final value) => value,
          _ => null,
        };
        return Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: (b ?? false) ? Colors.green : Colors.redAccent,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [Text(displayText), Text(b?.toString() ?? 'Unknown')],
          ),
        );
      },
    );
  }
}

/// A class that displays a number from NetworkTables.
class NumberDisplayTile extends StatelessWidget {
  late final NTValueNotifier notifier;
  late final String displayText;
  final Color? color;
  final int decimalPlaces;
  NumberDisplayTile({
    super.key,
    required String valueName,
    this.color,
    String? displayText,
    this.decimalPlaces = 3,
  }) {
    notifier = NTValueNotifier.fromName(valueName: valueName, inst: inst);
    this.displayText = displayText ?? valueName;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, child) {
        double? n = switch (notifier.currentValue) {
          NTDoubleValue(:final value) => value,
          NTIntegerValue(:final value) => value as double,
          _ => null,
        };

        return Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Text(displayText),
              Text(n?.toStringAsFixed(decimalPlaces) ?? 'Unknown'),
            ],
          ),
        );
      },
    );
  }
}

/// A class that displays a number from NetworkTables and changes
/// color based on the number.
class NumberColorChangeTile extends StatelessWidget {
  late final NTValueNotifier notifier;
  late final String displayText;
  final Color Function(double?) colorPicker;
  final int decimalPlaces;
  NumberColorChangeTile({
    super.key,
    required String valueName,
    required this.colorPicker,
    String? displayText,
    this.decimalPlaces = 3,
  }) {
    notifier = NTValueNotifier.fromName(valueName: valueName, inst: inst);
    this.displayText = displayText ?? valueName;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, child) {
        double? n = switch (notifier.currentValue) {
          NTDoubleValue(:final value) => value,
          NTIntegerValue(:final value) => value as double,
          _ => null,
        };

        return Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: colorPicker(n),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Text(displayText),
              Text(n?.toStringAsFixed(decimalPlaces) ?? 'Unknown'),
            ],
          ),
        );
      },
    );
  }
}

/// A class that displays a string from NetworkTables.
class StringDisplayTile extends StatelessWidget {
  late final NTValueNotifier notifier;
  late final String displayText;
  final Color? color;
  StringDisplayTile({
    super.key,
    required String valueName,
    this.color,
    String? displayText,
  }) {
    notifier = NTValueNotifier.fromName(valueName: valueName, inst: inst);
    this.displayText = displayText ?? valueName;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, child) {
        String? s = switch (notifier.currentValue) {
          NTStringValue(:final value) => value,
          _ => null,
        };

        return Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [Text(displayText), Text(s ?? 'Unknown')],
          ),
        );
      },
    );
  }
}

class IncrementableCounterTile extends StatelessWidget {
  late final NTValueNotifier notifier;
  late final String displayText;
  final Color? color;
  final String valueName;
  IncrementableCounterTile({
    super.key,
    required this.valueName,
    this.color,
    String? displayText,
  }) {
    notifier = NTValueNotifier.fromName(valueName: valueName, inst: inst);
    this.displayText = displayText ?? valueName;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, child) {
        // java default puts everything as doubles
        double? n = switch (notifier.currentValue) {
          NTIntegerValue(:final value) => value as double,
          NTDoubleValue(:final value) => value,
          _ => null,
        };

        return Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (n != null) {
                    inst.setEntryDouble(valueName, n + 1);
                  }
                },
                child: Text('+'),
              ),
              Text('$displayText ${n?.toStringAsFixed(0) ?? 'Unknown'}'),

              ElevatedButton(
                onPressed: () {
                  if (n != null) {
                    inst.setEntryDouble(valueName, n - 1);
                  }
                },
                child: Text('-'),
              ),
            ],
          ),
        );
      },
    );
  }
}
