import 'package:aluminum/ntcore/values.dart';
import 'package:aluminum/ntreferences.dart';
import 'package:flutter/material.dart';

/// Map of state names to information to show the driver.
/// Populate this with specific information for a given bot.
/// TODO: add ability to customize this in settings instead
const Map<String, _StateDescription> _stateDescriptions = {
  'ExampleState': _StateDescription(
    swerveEnabled: true,
    description: 'Fill in a description of the state here...',
    bindingReminders: 'A does something, B does another thing, etc...',
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
                    'Robot is in: ',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                Align(
                  alignment: .centerRight,
                  child: Text(state, style: theme.textTheme.headlineSmall),
                ),
              ],
            ),
            Divider(),
            // List of bindings
            (description != null)
                ? Text(
                    'Swerve ${description.swerveEnabled ? 'Enabled' : 'Disabled'}',
                  )
                : Text('???'),
            Text(description?.description ?? 'No description available.'),
            Text(description?.bindingReminders ?? 'Binds unknown.'),
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
  final String? bindingReminders;

  const _StateDescription({
    this.description,
    this.swerveEnabled = false,
    this.bindingReminders,
  });
}
