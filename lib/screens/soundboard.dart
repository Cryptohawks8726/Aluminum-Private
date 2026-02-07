import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

typedef SoundItem = ({String assetPath, String name});

const List<SoundItem> sounds = [
  (assetPath: 'sounds/fahhhhhhhhhhhhhh.mp3', name: 'Fahhhh'),
  (
    assetPath: 'sounds/lack-of-a-father-figure.mp3',
    name: 'Lack of a Father Figure',
  ),
  (assetPath: 'sounds/outro-song_oqu8zAg.mp3', name: 'Outro Song'),
  (assetPath: 'sounds/test-sound.mp3', name: 'Test Sound'),
  (assetPath: 'sounds/vine-boom.mp3', name: 'Vine Boom'),
  // (
  //   assetPath: 'sounds/we-are-charlie-kirk-song.mp3',
  //   name: 'We Are Charlie Kirk',
  // ),
  (assetPath: 'sounds/rahh-skeletons.mp3', name: 'SKELETON RAHHHH'),
];

class SoundboardScreen extends StatefulWidget {
  const SoundboardScreen({super.key});
  @override
  State<StatefulWidget> createState() => _SoundboardScreenState();
}

class _SoundboardScreenState extends State<SoundboardScreen> {
  double vol = 1.0;
  _SoundboardScreenState();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SOUNDBOARD 🤣😹😂🫵🫵🫵',
              style: theme.textTheme.displaySmall,
            ),
          ),
          const Divider(),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
              ),
              itemCount: sounds.length,
              itemBuilder: (ctx, index) {
                final sound = sounds[index];
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onPressed: () async {
                      final player = AudioPlayer()
                        ..setAsset(sound.assetPath)
                        ..setVolume(vol);
                      await player.play();
                      await for (final state in player.processingStateStream) {
                        if (state == ProcessingState.completed) {
                          break;
                        }
                      }
                      await player.dispose();
                    },
                    child: Text(sound.name),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Text('Volume: '),
              Slider(
                value: vol,
                label: "Volume",
                onChanged: (double v) => setState(() {
                  vol = v;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
