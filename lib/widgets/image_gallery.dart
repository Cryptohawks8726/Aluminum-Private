import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// How long each image is shown before transitioning to the next one.
const imageShowTime = 5;
const imageFiles = <String>[
  '20250622_154326_IMG_2303.HEIC',
  '1e6ad462-ed40-4d67-959d-59fc4dbe40ca.jpg',
  '20251018_160032(1).jpg',
  '20251126_184452.jpg',
  '20251129_201716.jpg',
];

class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key});

  @override
  createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  Random rand = Random();
  late final Timer timer;

  _ImageGalleryState() {
    timer = Timer.periodic(Duration(seconds: imageShowTime), (t) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageFiles.isNotEmpty) {
      int idx = rand.nextInt(imageFiles.length);
      return Image(image: AssetImage('images/gallery/${imageFiles[idx]}'));
    } else {
      return const Text('no images :(');
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
}
