import 'package:flutter/material.dart';

// I'm guessing this will want to be stateful if we want to be able to change the listed
// widgets but I could be wrong so feel free to change it later.
class NTValuesDisplay extends StatefulWidget {
  const NTValuesDisplay({super.key});

  @override
  State<StatefulWidget> createState() => _NTValuesDisplayState();
}

// TODO: rework, make this functional.

class _NTValuesDisplayState extends State<NTValuesDisplay> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Align(
      alignment: .topLeft,
      child: Column(
        spacing: 10.0,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              spacing: 10.0,
              children: [
                // placeholder lunite counter example
                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      ElevatedButton(onPressed: () {}, child: Text('+')),
                      Text('Lunites: 3'),

                      ElevatedButton(onPressed: () {}, child: Text('-')),
                    ],
                  ),
                ),
                // true/false value example
                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [Text('This value is:'), Text('False')],
                  ),
                ),
                // number example
                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.inversePrimary,
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [Text('Some Number:'), Text('129.56')],
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
                // long widget example
                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Text('Super Long String Value:'),
                      Text('Woah This is A Really Long String from the Robot'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // last row is currently empty
          Expanded(flex: 1, child: Row()),
        ],
      ),
    );
  }
}
