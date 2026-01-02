import 'package:mjpeg_view/mjpeg_view.dart';
import 'package:driver_dashboard/util.dart';
import 'package:flutter/material.dart';

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
      child: Row(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          Expanded(
            flex: 2,
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
                        uri:
                            'http://61.211.241.239/nphMotionJpeg?Resolution=320x240&Quality=Standard',
                      ),
                    ),
                  ),

                  Expanded(
                    child: SizedBox(
                      child: MjpegView(
                        fit: BoxFit.contain,
                        errorWidget: cameraErrorWidget,
                        uri:
                            llCamUrls[1] ??
                            'http://webcam01.ecn.purdue.edu/mjpg/video.mjpg',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.fromLTRB(45.0, 10.0, 15.0, 10.0),
              child: Column(
                mainAxisAlignment: .spaceEvenly,
                crossAxisAlignment: .center,
                spacing: 10,
                children: [
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
                  // field view (TODO: Switch for proper field view widget)
                  Expanded(
                    flex: 2,
                    child: Image(image: AssetImage('images/2025-field.png')),
                  ),

                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .center,
                      spacing: 5.0,
                      children: [
                        // TODO: Break this out into its own widget and make it easy to provide a map of names to bindings/info
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Stack(
                                children: [
                                  Align(
                                    alignment: .centerLeft,
                                    child: Text(
                                      'Robot is currently in: ',
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                  ),
                                  Align(
                                    alignment: .centerRight,
                                    child: Text(
                                      'IdleToIntake',
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Table(
                                columnWidths: <int, TableColumnWidth>{
                                  0: FlexColumnWidth(),
                                  1: FlexColumnWidth(),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Text('A: Do X'),
                                      Text('B: Do X'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('X: Do X'),
                                      Text('Y: Do X'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('LB: Do X'),
                                      Text('RB: Do X'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('LT: Do X'),
                                      Text('RT: Do X'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('Start: Do X'),
                                      Text('Select: Do X'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('D-Up: Do X'),
                                      Text('D-Down: Do X'),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text('D-Left: Do X'),
                                      Text('D-Right: Do X'),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(),
                              Text('Swerve Enabled'),
                              Text(
                                'Free control over the robot while driving towards intaking pieces.',
                              ),
                            ],
                          ),
                        ),

                        VerticalDivider(),

                        // TODO: Break out into separate widget
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: .topLeft,
                            child: Column(
                              spacing: 10.0,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    spacing: 10.0,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: .center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {},
                                              child: Text('+'),
                                            ),
                                            Text('Lunites: 3'),

                                            ElevatedButton(
                                              onPressed: () {},
                                              child: Text('-'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: .center,
                                          children: [
                                            Text('This value is:'),
                                            Text('False'),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          color:
                                              theme.colorScheme.inversePrimary,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: .center,
                                          children: [
                                            Text('Some Number:'),
                                            Text('129.56'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    spacing: 10.0,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .secondaryContainer,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15.0),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: .center,
                                          children: [
                                            Text('Super Long String Value:'),
                                            Text(
                                              'Woah This is A Really Long String from the Robot',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(flex: 1, child: Row()),
                              ],
                            ),
                          ),
                        ),

                        VerticalDivider(),

                        // Maybe also break this out into another widget?
                        Stack(
                          children: [
                            Column(
                              mainAxisAlignment: .start,
                              mainAxisSize: .max,
                              spacing: 10.0,
                              crossAxisAlignment: .center,
                              children: [
                                Icon(Icons.control_camera, color: Colors.green),
                                Icon(Icons.two_wheeler, color: Colors.green),
                                Icon(Icons.battery_0_bar, color: Colors.red),
                              ],
                            ),
                            Align(
                              alignment: .bottomCenter,
                              child: FloatingActionButton.small(
                                onPressed: () {
                                  Scaffold.of(context).openEndDrawer();
                                },
                                child: Icon(Icons.menu),
                              ),
                            ),
                          ],
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
