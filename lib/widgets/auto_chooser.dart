import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:flutter/material.dart';

class AutoChooser extends StatefulWidget {
  const AutoChooser({super.key});

  @override
  State<StatefulWidget> createState() => _AutoChooserState();
}

class _AutoChooserState extends State<AutoChooser> {
  String? selectedVal;
  List<String> opts = [];

  _AutoChooserState() {
    autoChooserOptionsNotifier.addListener(updateOptions);
    autoChooserSelectedNotifier.addListener(updateValue);
    getNewOptions();
    getNewSelected();
  }

  @override
  void dispose() {
    super.dispose();
    autoChooserOptionsNotifier.removeListener(updateOptions);
    autoChooserSelectedNotifier.removeListener(updateValue);
  }

  void updateValue() {
    setState(() => getNewSelected());
  }

  void updateOptions() {
    setState(() => getNewOptions());
  }

  void getNewOptions() {
    switch (autoChooserOptionsNotifier.currentValue) {
      case NTStringArrayValue(:final value):
        opts = value;
        getNewSelected();
        break;
      default:
        opts = [];
        break;
    }
  }

  void getNewSelected() {
    switch (autoChooserSelectedNotifier.currentValue) {
      case NTStringValue(:final value):
        if (value.isNotEmpty) {
          selectedVal = value;
        }
        break;
      default:
        selectedVal = null;
        break;
    }

    if (selectedVal != null && !opts.contains(selectedVal)) {
      opts.add(selectedVal!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Selected Auto:'),
        DropdownButton<String>(
          onChanged: (String? val) {
            if (val != null) {
              inst.setEntryString(autoChooserSelectedPath, val);
            } else {
              inst.setEntryString(autoChooserSelectedPath, '');
            }
          },
          items:
              opts
                  .map(
                    (String s) =>
                        DropdownMenuItem<String>(value: s, child: Text(s)),
                  )
                  .toList()
                ..add(DropdownMenuItem(value: null, child: Text('None'))),

          value: selectedVal,
        ),
      ],
    );
  }
}
