import 'package:flutter/material.dart';

class StateBindingsDisplay extends StatelessWidget {
  const StateBindingsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
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
        // List of bindings
        Table(
          columnWidths: <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
          },
          children: [
            TableRow(children: [Text('A: Do X'), Text('B: Do X')]),
            TableRow(children: [Text('X: Do X'), Text('Y: Do X')]),
            TableRow(children: [Text('LB: Do X'), Text('RB: Do X')]),
            TableRow(children: [Text('LT: Do X'), Text('RT: Do X')]),
            TableRow(children: [Text('Start: Do X'), Text('Select: Do X')]),
            TableRow(children: [Text('D-Up: Do X'), Text('D-Down: Do X')]),
            TableRow(children: [Text('D-Left: Do X'), Text('D-Right: Do X')]),
          ],
        ),
        Divider(),
        Text('Swerve Enabled'),
        Text(
          'Free control over the robot while driving towards intaking pieces.',
        ),
      ],
    );
  }
}
