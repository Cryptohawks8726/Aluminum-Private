import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// ADD SOUNDS HERE
const sounds = <({String assetPath, String name})>[
  (assetPath: 'sounds/test-sound.mp3', name: 'Test Sound'),
];

class SoundboardScreen extends StatelessWidget {
  final players = sounds
      .map((data) {
        return AudioPlayer()..setAsset(data.assetPath);
      })
      .toList(growable: false);

  SoundboardScreen({super.key});

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
                crossAxisCount: 6,
              ),
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: EdgeInsetsGeometry.all(10.0),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onPressed: () {
                      players[index].play();
                    },
                    child: Text(sounds[index].name),
                  ),
                );
              },
              itemCount: sounds.length,
            ),
          ),
        ],
      ),
    );
  }
}
