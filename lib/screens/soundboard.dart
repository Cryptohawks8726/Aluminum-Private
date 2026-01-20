import 'package:flutter/material.dart';

class SoundboardScreen extends StatelessWidget {
  const SoundboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsGeometry.all(16.0),
      child: Column(
        children: [
          // Title bar and buttons
          Align(
            alignment: .centerLeft,
            child: Text(
              'SOUNDBOARD 🤣😹😂🫵🫵🫵',
              style: theme.textTheme.displaySmall,
            ),
          ),
          const Divider(),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (ctx, index) {
                return Text('hi');
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
