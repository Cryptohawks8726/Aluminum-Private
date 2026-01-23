import 'package:aluminum/ntcore/instance.dart';
import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _newMotorCanIDPath = '/SmartDashboard/Add Motors/CAN ID';
const _newMotorTypePath = '/SmartDashboard/Add Motors/Motor Type';
const _motorTypesPath = '/SmartDashboard/Add Motors/Motor Types';
const _publishMotorPath = '/SmartDashboard/Add Motors/publish';
const _usedCanIDsList = '/SmartDashboard/Add Motors/Used CAN IDs';
const _motorsPath = '/SmartDashboard/Motors';

class MotorTestingScreen extends StatefulWidget {
  const MotorTestingScreen({super.key});

  @override
  createState() => _MotorTestingScreenState();
}

class _MotorTestingScreenState extends State<MotorTestingScreen> {
  final canIDController = TextEditingController(text: '1');
  // Paths for use with MotorTesting repo
  // These notifiers are kept here to save resources
  // so we aren't listening in on them when the motor testing panel
  // isn't in use.
  final newMotorCanIDNotifier = NTValueNotifier.fromName(
    valueName: _newMotorCanIDPath,
    inst: inst,
  );
  final newMotorTypeNotifier = NTValueNotifier.fromName(
    valueName: _newMotorTypePath,
    inst: inst,
  );
  final motorTypesNotifier = NTValueNotifier.fromName(
    valueName: _motorTypesPath,
    inst: inst,
  );
  final usedCanIDsNotifier = NTValueNotifier.fromName(
    valueName: _usedCanIDsList,
    inst: inst,
  );
  final canIDFocusNode = FocusNode();
  List<String>? motorTypes;
  String? selectedMotorType;
  Map<int, _MotorWidget> motors = {};

  _MotorTestingScreenState() {
    newMotorCanIDNotifier.addListener(() {
      final val = newMotorCanIDNotifier.currentValue;
      if (val is NTIntegerValue) {
        canIDController.text = val.toString();
      }
    });
    newMotorTypeNotifier.addListener(() {
      final val = newMotorTypeNotifier.currentValue;
      if (val is NTStringValue) {
        setState(() {
          selectedMotorType = val.value;
        });
      } else {
        selectedMotorType = null;
      }
    });
    motorTypesNotifier.addListener(updateMotorTypes);
    usedCanIDsNotifier.addListener(updateMotorsList);
    canIDFocusNode.addListener(() {
      if (!canIDFocusNode.hasFocus) {
        updateCanID();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    updateMotorsList();
    updateMotorTypes();
  }

  @override
  void dispose() {
    NTValueNotifier.stopNotifying(_newMotorCanIDPath);
    NTValueNotifier.stopNotifying(_newMotorTypePath);
    NTValueNotifier.stopNotifying(_motorTypesPath);
    newMotorCanIDNotifier.dispose();
    newMotorTypeNotifier.dispose();
    motorTypesNotifier.dispose();
    canIDFocusNode.dispose();

    super.dispose();
  }

  void updateMotorTypes() {
    final val = motorTypesNotifier.currentValue;
    if (val is NTStringArrayValue) {
      setState(() {
        motorTypes = val.value;
      });
    }
  }

  void updateMotorsList() {
    final val = usedCanIDsNotifier.currentValue;
    if (val is NTIntegerArrayValue) {
      setState(() {
        // Add new motors
        for (var i in val.value) {
          if (!motors.containsKey(i)) {
            motors[i] = _MotorWidget(i);
          }
        }

        // Remove any motors which are no longer used
        var keysDupe = motors.keys.toList(growable: false);
        for (var i in keysDupe) {
          if (!val.value.contains(i)) {
            motors[i]?.dispose();
            motors.remove(i);
          }
        }
      });
    }
  }

  void updateCanID() {
    int? id = int.tryParse(canIDController.text);
    if (id != null) {
      inst.setEntryInt(_newMotorCanIDPath, id);
    }
  }

  // For convenience, since build() is a mess
  Widget buildDropdownMotorType() {
    var types = motorTypes ?? ['None'];
    return DropdownButton<String>(
      items: types
          .map((String s) {
            return DropdownMenuItem<String>(value: s, child: Text(s));
          })
          .toList(growable: false),
      onChanged: (val) {
        selectedMotorType = val;
        if (val != null) {
          inst.setEntryString(_newMotorTypePath, val);
        }
      },
      value: selectedMotorType ?? types.first,
    );
  }

  List<TableRow> getMotorTableRows(BuildContext context) {
    var theme = Theme.of(context);
    var rows = motors.values.toList(growable: false);
    var out = <TableRow>[];
    for (int i = 0; i < rows.length; i++) {
      out.add(
        rows[i].buildRow(
          i % 2 == 0
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer,
        ),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          children: [
            Align(
              alignment: .centerLeft,
              child: Text(
                'Motor Testing Panel',
                style: theme.textTheme.displaySmall,
              ),
            ),
            Align(
              alignment: .centerRight,
              child: Text(
                'Will only work with the code from the MotorTesting repo!',
              ),
            ),
          ],
        ),

        const Divider(),

        // Options to add motors
        Row(
          spacing: 12.0,
          mainAxisAlignment: .spaceEvenly,
          crossAxisAlignment: .center,
          children: [
            Text('Motor CAN ID: '),
            SizedBox(
              width: 150,
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => updateCanID,
                controller: canIDController,
                focusNode: canIDFocusNode,
              ),
            ),
            Text('Motor Type: '),
            buildDropdownMotorType(),
            FilledButton(
              onPressed: () {
                inst.setEntryBool(_publishMotorPath, true);
              },
              child: const Text('Add Motor'),
            ),
          ],
        ),

        const Divider(),

        // List of motors to edit
        Expanded(
          child: Table(
            defaultVerticalAlignment: .middle,
            columnWidths: {
              0: FractionColumnWidth(0.3),
              1: FractionColumnWidth(0.2),
              2: FractionColumnWidth(0.2),
              3: FractionColumnWidth(0.3),
            },
            children: getMotorTableRows(context),
          ),
        ),
      ],
    );
  }
}

class _MotorWidget {
  final voltageEditController = TextEditingController();
  final voltageEditFocusNode = FocusNode();
  late final int canID;
  late final String posPath;
  late final NTValueNotifier posNotifier;
  late final String velPath;
  late final NTValueNotifier velNotifier;
  late final String voltagePath;
  late final NTValueNotifier voltageNotifier;

  _MotorWidget(int id) {
    canID = id;
    posPath = '$_motorsPath/$id/Position';
    posNotifier = NTValueNotifier.fromName(valueName: posPath, inst: inst);
    velPath = '$_motorsPath/$id/Velocity';
    velNotifier = NTValueNotifier.fromName(valueName: velPath, inst: inst);
    voltagePath = '$_motorsPath/$id/Voltage';
    voltageNotifier = NTValueNotifier.fromName(
      valueName: voltagePath,
      inst: inst,
    );

    voltageEditFocusNode.addListener(() {
      if (!voltageEditFocusNode.hasFocus) {
        sendVoltage();
      }
    });
  }

  void sendVoltage() {
    var val = double.tryParse(voltageEditController.text);
    if (val != null) {
      inst.setEntryDouble(voltagePath, val);
    }
  }

  // TRIPLE LISTENABLE BULIDER BECAUSE I CANNOT BE BOTHERED!!!!!!!!
  TableRow buildRow(Color rowColor) {
    return TableRow(
      decoration: BoxDecoration(color: rowColor),
      children: [
        Center(child: Text('Motor $canID')),
        Align(
          alignment: .center,
          child: ListenableBuilder(
            listenable: posNotifier,
            builder: (context, child) {
              return Text('Position: ${posNotifier.currentValue.toString()}');
            },
          ),
        ),
        Align(
          alignment: .center,
          child: ListenableBuilder(
            listenable: velNotifier,
            builder: (context, child) {
              return Text('Velocity: ${velNotifier.currentValue.toString()}');
            },
          ),
        ),
        Align(
          alignment: .center,
          child: ListenableBuilder(
            listenable: voltageNotifier,
            builder: (context, child) {
              final voltsVal = voltageNotifier.currentValue;
              if (voltsVal is NTDoubleValue) {
                voltageEditController.text = voltsVal.value.toString();
              }

              return Padding(
                padding: EdgeInsetsGeometry.all(10.0),
                child: Row(
                  spacing: 10.0,
                  mainAxisAlignment: .center,
                  children: [
                    Text('Voltage: '),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: voltageEditController,
                        selectAllOnFocus: false,
                        onSubmitted: (_) => sendVoltage,
                        focusNode: voltageEditFocusNode,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void dispose() {
    NTValueNotifier.stopNotifying(voltagePath);
    NTValueNotifier.stopNotifying(posPath);
    NTValueNotifier.stopNotifying(velPath);
    posNotifier.dispose();
    velNotifier.dispose();
    voltageNotifier.dispose();
    voltageEditFocusNode.dispose();
  }
}
