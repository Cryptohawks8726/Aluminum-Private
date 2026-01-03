import 'package:driver_dashboard/settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

/// Acts both as a state for the settings screen and
/// as the globally accessible app settings.

class _SettingsScreenState extends State<SettingsScreen> {
  final formKey = GlobalKey<FormState>();
  var instanceCopy = Settings.copyInstance();
  late var teamNumberController = TextEditingController(
    text: instanceCopy.teamNumber.toString(),
  );
  late var portController = TextEditingController(
    text: instanceCopy.port.toString(),
  );
  late var serverNameController = TextEditingController(
    text: instanceCopy.serverName,
  );
  late var cameraControllers = instanceCopy.cameraURLs.map((String url) {
    return TextEditingController(text: url);
  }).toList();
  bool valuesAreValid = true;

  bool save(BuildContext context) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Settings.overwriteSettings(instanceCopy);
      instanceCopy = Settings.copyInstance();
      // Sends a SnackBar to inform the user changes were saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Changes saved successfully.'),
          duration: Duration(milliseconds: 750),
        ),
      );
      return true;
    } else {
      return false;
    }
  }

  void loadJSON(BuildContext context) async {
    var files = await FilePicker.platform.pickFiles(
      dialogTitle: 'Save Dashboard Settings',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files != null && files.paths.isNotEmpty) {
      if (Settings.tryLoadSettingsFromJSON(files.paths.first!)) {
        setState(() {
          instanceCopy = Settings.copyInstance();
          teamNumberController.text = instanceCopy.teamNumber.toString();
          portController.text = instanceCopy.port.toString();
          serverNameController.text = instanceCopy.serverName;
          for (int i = 0; i < cameraControllers.length; i++) {
            cameraControllers[i].text = instanceCopy.cameraURLs[i];
          }
        });
      }
    }
  }

  void exportJSON(BuildContext context) async {
    if (!save(context)) {
      return;
    }

    var path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Dashboard Settings',
      type: FileType.custom,
      allowedExtensions: ['.json'],
    );
    if (path != null) {
      Settings.exportJSONSettings(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: 20.0),
      child: Padding(
        padding: EdgeInsetsGeometry.all(16.0),
        child: Column(
          children: [
            // Title bar and buttons
            Stack(
              children: [
                Align(
                  alignment: .centerLeft,
                  child: Text(
                    'Dashboard Settings',
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                Align(
                  alignment: .centerRight,
                  child: Row(
                    mainAxisSize: .min,
                    spacing: 10.0,
                    children: [
                      FilledButton(
                        onPressed: () {
                          save(context);
                        },
                        child: Text('Save Changes'),
                      ),
                      FilledButton(
                        onPressed: () => exportJSON(context),
                        child: Text('Export as JSON'),
                      ),
                      FilledButton(
                        onPressed: () => loadJSON(context),
                        child: Text('Load from JSON'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(),

            // Form containing settings widgets
            Expanded(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // useNamedServer
                    CheckboxListTile(
                      title: Text(
                        'Use server name instead of team number when connecting',
                      ),
                      value: instanceCopy.useNamedServer,
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            instanceCopy.useNamedServer = value;
                          });
                        }
                      },
                    ),

                    // teamNumber
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Team Number',
                      ),
                      controller: teamNumberController,

                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (String? val) {
                        return val == null || val.isEmpty
                            ? 'Enter a team number'
                            : null;
                      },
                      onSaved: (String? val) {
                        if (val != null) {
                          instanceCopy.teamNumber = int.parse(val);
                        }
                      },
                    ),

                    // serverName
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Server Name',
                      ),
                      controller: serverNameController,
                      onSaved: (String? val) {
                        if (val != null) {
                          instanceCopy.serverName = val;
                        }
                      },
                    ),

                    // port
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Port'),
                      controller: portController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (String? val) {
                        return val == null || val.isEmpty
                            ? 'Enter a port'
                            : null;
                      },
                      onSaved: (String? val) {
                        if (val != null) {
                          instanceCopy.port = int.parse(val);
                        }
                      },
                    ),
                    ...
                    // Adds cameras
                    instanceCopy.cameraURLs.map((String url) {
                      var idx = instanceCopy.cameraURLs.indexOf(url);
                      return TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Camera ${idx + 1} Address',
                        ),
                        controller: cameraControllers[idx],
                        onSaved: (String? val) {
                          if (val != null) {
                            instanceCopy.cameraURLs[idx] = val;
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
