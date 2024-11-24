import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fwp/styles/styles.dart';
import 'package:fwp/widgets/app_image.dart';

double imageHeigth = 200;
double circularProgressIndicatorSize = 20;
double verticalPadding = 18;
Radius circularRadius = const Radius.circular(14);
BorderRadius borderRadius = BorderRadius.only(
  topLeft: circularRadius,
  topRight: circularRadius,
);

class EpisodeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String vimeoUrl;
  final String duration;
  final VoidCallback onPressed;

  const EpisodeCard({
    Key? key,
    required this.onPressed,
    required this.imageUrl,
    required this.title,
    required this.vimeoUrl,
    required this.duration,
  }) : super(key: key);

  BoxConstraints getConstraints(BuildContext context) {
    const maxWidth = 500.0;
    final maxWidgetWidth = MediaQuery.of(context).size.width - verticalPadding;

    return BoxConstraints(
      maxWidth: maxWidth,
      minWidth: maxWidgetWidth > maxWidth ? maxWidth : maxWidgetWidth,
    );
  }

  Color getBackgroundColor({bool isDarkMode = false}) {
    if (Platform.isMacOS) {
      return isDarkMode ? Colors.black : Colors.white;
    }
    return isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isAppInDarkMode(context);

    if (title == "" || imageUrl == "" || vimeoUrl == "") {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: verticalPadding, vertical: 12),
      child: Center(
        child: Container(
          constraints: getConstraints(context),
          decoration: BoxDecoration(
            color: getBackgroundColor(isDarkMode: isDarkMode),
            borderRadius: BorderRadius.all(circularRadius),
            boxShadow: isDarkMode
                ? null
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 1.0),
                      blurRadius: 16.0,
                    ),
                  ],
          ),
          child: InkWell(
            onTap: onPressed,
            child: Column(
              children: [
                Stack(
                  children: [
                    AppImage(
                      imageUrl: imageUrl,
                      height: imageHeigth,
                    ),
                    if (duration.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
