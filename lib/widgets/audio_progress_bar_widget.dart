import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:fwp/notifiers/notifiers.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:fwp/service_locator.dart';

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final playerManager = getIt<PlayerManager>();

    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: playerManager.progressNotifier,
      builder: (_, value, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProgressBar(
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
            onSeek: playerManager.seek,
          ),
        );
      },
    );
  }
}
