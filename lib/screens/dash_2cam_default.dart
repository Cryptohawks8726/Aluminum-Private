import 'package:driver_dashboard/settings.dart';
import 'package:driver_dashboard/widgets/field_view.dart';
import 'package:driver_dashboard/widgets/nt_values_display.dart';
import 'package:driver_dashboard/widgets/state_bindings.dart';
import 'package:mjpeg_view/mjpeg_view.dart';
import 'package:driver_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Default2CamDashboard extends StatefulWidget {
  const Default2CamDashboard({super.key});

  @override
  State<Default2CamDashboard> createState() => _Default2CamDashboardState();
}

class _Default2CamDashboardState extends State<Default2CamDashboard> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: 18.0),
      // 2-column layout row
      child: Row(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          Expanded(
            flex: 2,
            // Container with both camera views
            child: Container(
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 45.0, 10.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    theme.colorScheme.primaryContainer,
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: [0.8, 1.0],
                ),
              ),
              child: Column(
                spacing: 30,
                mainAxisAlignment: .center,
                mainAxisSize: .max,
                children: [
                  // limelight cameras are 4:3 aspect ratio
                  Expanded(
                    child: SizedBox(
                      child: MjpegView(
                        fit: BoxFit.contain,
                        errorWidget: cameraErrorWidget,
                        uri: Settings.getCameraURLs[0],
                      ),
                    ),
                  ),

                  Expanded(
                    child: SizedBox(
                      child: MjpegView(
                        fit: BoxFit.contain,
                        errorWidget: cameraErrorWidget,
                        uri: Settings.getCameraURLs[1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side column with rest of dashboard
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.fromLTRB(45.0, 10.0, 15.0, 10.0),
              child: Column(
                mainAxisAlignment: .spaceEvenly,
                crossAxisAlignment: .center,
                spacing: 10,
                children: [
                  // Top status bar (match #, time, alliance)
                  Stack(
                    children: [
                      Align(
                        alignment: .centerLeft,
                        child: Text(
                          'Match 1',
                          style: theme.textTheme.displaySmall,
                        ),
                      ),
                      Align(
                        alignment: .center,
                        child: Text(
                          '-:--',
                          style: theme.textTheme.displayLarge,
                        ),
                      ),
                      Align(
                        alignment: .centerRight,
                        child: Text(
                          'Blue Alliance',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // field view with robot overlay
                  Expanded(flex: 2, child: FieldViewWidget()),

                  // Lower section under field
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .center,
                      spacing: 5.0,
                      children: [
                        // State info and bindings
                        Expanded(flex: 1, child: StateBindingsDisplay()),

                        VerticalDivider(),

                        // List of custom displayed values
                        Expanded(flex: 1, child: NTValuesDisplay()),

                        VerticalDivider(),

                        // Maybe also break this out into another widget later?
                        // Status icons
                        // The SizedOverflowBox is to leave room for the FloatingActionButton
                        // otherwise it falls on top of the divider and looks weird.
                        SizedOverflowBox(
                          size: Size(48.0, 0.0),
                          child: Column(
                            mainAxisAlignment: .start,
                            mainAxisSize: .max,
                            spacing: 10.0,
                            crossAxisAlignment: .center,
                            children: [
                              // these are all meaningless placeholders
                              Icon(Icons.control_camera, color: Colors.green),
                              Icon(Icons.two_wheeler, color: Colors.green),
                              Icon(Icons.battery_0_bar, color: Colors.red),
                            ],
                          ),
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
