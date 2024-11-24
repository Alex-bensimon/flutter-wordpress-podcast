import 'package:flutter/material.dart';
import 'package:fwp/notifiers/notifiers.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:fwp/styles/styles.dart';
import 'package:fwp/widgets/app_image.dart';
import 'package:fwp/service_locator.dart';

class AudioMetaData extends StatelessWidget {
  const AudioMetaData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerManager = getIt<PlayerManager>();
    final screenWidth = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<MetaDataAudioState>(
      valueListenable: playerManager.metaDataAudioNotifier,
      builder: (_, value, __) {
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EpisodeImage(
                audioUri: value.artUri,
                imageMaxWidth: screenWidth > 350 ? 300 : 200,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  value.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EpisodeImage extends StatelessWidget {
  final Uri audioUri;
  final double imageMaxWidth;

  const EpisodeImage({
    Key? key,
    required this.audioUri,
    required this.imageMaxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isAppInDarkMode(context);

    return Container(
      constraints: BoxConstraints(maxWidth: imageMaxWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AppImage(
          imageUrl: audioUri.toString(),
          height: imageMaxWidth,
        ),
      ),
    );
  }
}
