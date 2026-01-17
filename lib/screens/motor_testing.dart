import 'package:aluminum/ntcore/instance.dart';
import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _newMotorCanIDPath = '/SmartDashboard/Add Motors/CAN ID';
const _newMotorTypePath = '/SmartDashboard/Add Motors/Motor Type';
const _motorTypesPath = '/SmartDashboard/Add Motors/Motor Types';
const _publishMotorPath = '/SmartDashboard/Add Motors/publish';

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
  List<String>? motorTypes;
  String? selectedMotorType;

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

  void updateCanID(String s) {
    int? id = int.tryParse(s);
    if (id != null) {}
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
                'Please deploy code from the MotorTesting repo first to use this correctly!',
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
              width: 250,
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: updateCanID,
                controller: canIDController,
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

        // List of motors to edite
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, idx) {
              return Text('hi');
            },
          ),
        ),
      ],
    );
  }
}

// For convenience.
class _DropdownMotorType extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(items: [], onChanged: (val) {});
  }
}
