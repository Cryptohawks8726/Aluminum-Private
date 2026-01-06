import 'package:driver_dashboard/ntcore/values.dart';
import 'package:driver_dashboard/ntreferences.dart';
import 'package:flutter/material.dart';

const Map<String, _StateDescription> _stateDescriptions = {
  'IdleToIntake': _StateDescription(
    swerveEnabled: true,
    onA: 'Some Wacky Action',
    onB: 'Some Crazy Action',
    description: 'Driving towards lunites to intake them.',
  ),
};

class StateBindingsDisplay extends StatelessWidget {
  const StateBindingsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ListenableBuilder(
      listenable: stateNotifier,
      builder: (context, child) {
        final String state = switch (stateNotifier.currentValue) {
          NTStringValue(:final value) => value,
          _ => 'Unknown',
        };

        final _StateDescription? description = _stateDescriptions[state];

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
                  child: Text(state, style: theme.textTheme.headlineMedium),
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
                TableRow(
                  children: [
                    Text('A: ${description?.onA ?? 'None'}'),
                    Text('B: ${description?.onB ?? 'None'}'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('X: ${description?.onX ?? 'None'}'),
                    Text('Y: ${description?.onY ?? 'None'}'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('LB: ${description?.onLB ?? 'None'}'),
                    Text('RB: ${description?.onRB ?? 'None'}'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('LT: ${description?.onLT ?? 'None'}'),
                    Text('RT: ${description?.onRT ?? 'None'}'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Start: ${description?.onStart ?? 'None'}'),
                    Text('Select: ${description?.onSelect ?? 'None'}'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('D-Up: ${description?.onDUp ?? 'None'}'),
                    Text('D-Down: ${description?.onDDown ?? 'None'}'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('D-Left: ${description?.onDLeft ?? 'None'}'),
                    Text('D-Right: ${description?.onDRight ?? 'None'}'),
                  ],
                ),
              ],
            ),
            Divider(),
            (description != null)
                ? Text(
                    'Swerve ${description.swerveEnabled ? 'Enabled' : 'Disabled'}',
                  )
                : Text('???'),
            Text(description?.description ?? '???'),
          ],
        );
      },
    );
  }
}

/// Class describing the different binds in a state and providing
/// flavor text and information about the state.
@immutable
class _StateDescription {
  final bool swerveEnabled;
  final String? description;
  final String? onA;
  final String? onB;
  final String? onX;
  final String? onY;
  final String? onLB;
  final String? onLT;
  final String? onRB;
  final String? onRT;
  final String? onStart;
  final String? onSelect;
  final String? onDUp;
  final String? onDLeft;
  final String? onDDown;
  final String? onDRight;

  const _StateDescription({
    this.description,
    this.swerveEnabled = false,
    this.onA,
    this.onB,
    this.onX,
    this.onY,
    this.onLB,
    this.onLT,
    this.onRT,
    this.onRB,
    this.onStart,
    this.onSelect,
    this.onDDown,
    this.onDLeft,
    this.onDRight,
    this.onDUp,
  });
}
