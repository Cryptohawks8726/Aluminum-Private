import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:aluminum/settings.dart';
import 'package:aluminum/widgets/field_view.dart';
import 'package:aluminum/widgets/nt_values_display.dart';
import 'package:aluminum/widgets/state_bindings.dart';
import 'package:mjpeg_view/mjpeg_view.dart';
import 'package:aluminum/util.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
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
              child: Builder(
                builder: (context) {
                  var children = Settings.getCameraURLs
                      .map<Widget>((String s) {
                        return Expanded(
                          child: SizedBox(
                            child: MjpegView(
                              fit: BoxFit.contain,
                              errorWidget: cameraErrorWidget,
                              uri: Settings.getCameraURLs[0],
                            ),
                          ),
                        );
                      })
                      .toList(growable: false);
                  return Column(
                    spacing: 30,
                    mainAxisAlignment: .center,
                    mainAxisSize: .max,
                    children: children,
                  );
                },
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
                  // Messy since it's a bunch of ListenableBuilders - could maybe
                  // move this to another function or something

                  // Match Number
                  Stack(
                    children: [
                      Align(
                        alignment: .centerLeft,
                        child: ListenableBuilder(
                          listenable: matchNumberNotifier,
                          builder: (context, child) {
                            int? num =
                                switch (matchNumberNotifier.currentValue) {
                                  NTIntegerValue(:final value) =>
                                    value > 0 ? value : null,
                                  _ => null,
                                };
                            return Text(
                              (num != null) ? 'Match $num' : 'No Active Match',
                              style: theme.textTheme.displaySmall,
                            );
                          },
                        ),
                      ),

                      // Game Time
                      Align(
                        alignment: .center,
                        child: ListenableBuilder(
                          listenable: gameTimeNotifier,
                          builder: (context, child) {
                            double? t = switch (gameTimeNotifier.currentValue) {
                              NTDoubleValue(:final value) =>
                                value >= 0.0 ? value : null,
                              _ => null,
                            };
                            return Text(
                              (t != null)
                                  ? formatTime(timeInSeconds: t.toInt())
                                  : '-:--',
                              style: theme.textTheme.displayLarge,
                            );
                          },
                        ),
                      ),

                      // Alliance
                      Align(
                        alignment: .centerRight,
                        child: ListenableBuilder(
                          listenable: isRedAllianceNotifier,
                          builder: (context, child) {
                            switch (isRedAllianceNotifier.currentValue) {
                              case NTBooleanValue(:final value):
                                if (value) {
                                  return Text(
                                    'Red Alliance',
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(color: Colors.red),
                                  );
                                } else {
                                  return Text(
                                    'Blue Alliance',
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(color: Colors.blueAccent),
                                  );
                                }
                              default:
                                return Text(
                                  'Unknown Alliance',
                                  style: theme.textTheme.displaySmall,
                                );
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  // field view with robot overlay
                  Expanded(flex: 3, child: FieldViewWidget()),

                  // Lower section under field
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .center,
                      spacing: 5.0,
                      children: [
                        // State info and bindings
                        Expanded(flex: 1, child: StateBindingsDisplay()),

                        VerticalDivider(),

                        // List of custom displayed values
                        Expanded(
                          flex: 1,
                          child: NTValuesDisplay(
                            children: [
                              BooleanDisplayTile(
                                valueName: '/FMSInfo/IsRedAlliance',
                                displayText: 'Are we red?',
                              ),
                              NumberDisplayTile(
                                valueName: '/SmartDashboard/gameTime',
                                displayText: 'Game Time (Seconds):',
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                              NumberColorChangeTile(
                                valueName: '/SmartDashboard/luniteCount',
                                displayText: 'Lunite Count: ',
                                decimalPlaces: 0,
                                colorPicker: (double? n) {
                                  if (n != null) {
                                    if (n >= 3) {
                                      return Colors.green;
                                    } else if (n > 0) {
                                      return Colors.yellow.shade800;
                                    }
                                  }
                                  return Colors.redAccent;
                                },
                              ),
                              StringDisplayTile(
                                valueName: '/SmartDashboard/currentState',
                                displayText: 'Robot is in',
                              ),
                              IncrementableCounterTile(
                                valueName: '/SmartDashboard/luniteCount',
                                displayText: 'Lunite Count: ',
                              ),
                            ],
                          ),
                        ),

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
                              ListenableBuilder(
                                listenable: inst.connectionNotifier,
                                builder: (context, child) {
                                  if (inst.connectionNotifier.isConnected) {
                                    return Icon(
                                      Icons.wifi_tethering,
                                      color: Colors.green,
                                    );
                                  } else {
                                    return Icon(
                                      Icons.wifi_tethering_error,
                                      color: Colors.red,
                                    );
                                  }
                                },
                              ),
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
