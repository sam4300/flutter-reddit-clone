import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/theme/palette.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToPostTypeScreen(BuildContext context, String type) {
    Routemaster.of(context).push('/post-type-screen/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardHeightWidth = 120;
    double iconSize = 60;
    final themeData = ref.watch(themeNotifierProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => navigateToPostTypeScreen(context, 'Image'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: themeData.colorScheme.background,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToPostTypeScreen(context, 'Text'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: themeData.colorScheme.background,
              child: Center(
                child: Icon(
                  Icons.font_download_outlined,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToPostTypeScreen(context, 'Link'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: themeData.colorScheme.background,
              child: Center(
                child: Icon(
                  Icons.link_outlined,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
