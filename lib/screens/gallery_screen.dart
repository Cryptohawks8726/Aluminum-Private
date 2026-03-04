import 'package:aluminum/widgets/image_gallery.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Image Gallery', style: theme.textTheme.displaySmall),
          ),
          const Divider(),
          Expanded(child: ImageGallery()),
        ],
      ),
    );
  }
}
