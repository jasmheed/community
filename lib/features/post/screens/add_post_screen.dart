import 'package:community/theme/pallete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardHeightWidth = kIsWeb ? (screenWidth * 0.4).clamp(120, 360) : 120;
    double iconSize = kIsWeb ? (cardHeightWidth / 3) : 60;

    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: kIsWeb
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Routemaster.of(context).pop();
                },
              )
            : null,
        title: Text('Add Post'),
        centerTitle: true,
      ),
      body: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                navigateToType(context, 'image');
              },
              child: SizedBox(
                height: cardHeightWidth,
                width: cardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: currentTheme.colorScheme.surface,
                  elevation: 16,
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
              onTap: () {
                navigateToType(context, 'text');
              },
              child: SizedBox(
                height: cardHeightWidth,
                width: cardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: currentTheme.colorScheme.surface,
                  elevation: 16,
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
              onTap: () {
                navigateToType(context, 'link');
              },
              child: SizedBox(
                height: cardHeightWidth,
                width: cardHeightWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: currentTheme.colorScheme.surface,
                  elevation: 16,
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
        ),
      ),
    );
  }
}
