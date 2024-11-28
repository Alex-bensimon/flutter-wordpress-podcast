import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fwp/blocs/blocs.dart';
import 'package:fwp/models/models.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:fwp/screens/screens.dart';
import 'package:fwp/styles/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fwp/services/video_downloader.dart';
import 'package:get_it/get_it.dart';

const paddingItems = 18.0;

class ListItem extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData iconData;
  final String text;
  const ListItem({
    Key? key,
    required this.iconData,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(
        iconData,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}

class EpisodeOptions extends StatelessWidget {
  final Episode episode;
  final app = dotenv.env['APP'];

  EpisodeOptions({
    Key? key,
    required this.episode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isAppInDarkMode(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 5,
                width: 42,
                color: isDarkMode ? Colors.grey : Colors.black38,
              ),
            ),
          ),
          if (episode.vimeoUrl.isNotEmpty)
            ListItem(
              iconData: Icons.play_circle_outline,
              text: "Regarder la vidéo",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(episode: episode),
                  ),
                );
              },
            ),
          ListItem(
            iconData: Icons.info_sharp,
            text: "Plus d'info sur l'épisode",
            onTap: () async {
              Navigator.pop(context);
              if (app == APP.thinkerview.name) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpisodeDetailsCaptainFact(
                      episode: episode,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpisodeDetails(
                      episode: episode,
                    ),
                  ),
                );
              }
            },
          ),
          FutureBuilder<bool>(
            future: VideoDownloader.isVideoDownloaded(episode),
            builder: (context, snapshot) {
              final isDownloaded = snapshot.data ?? false;

              return ListItem(
                iconData: isDownloaded ? Icons.download_done : Icons.download,
                text:
                    isDownloaded ? "Vidéo téléchargée" : "Télécharger la vidéo",
                onTap: isDownloaded
                    ? null
                    : () async {
                        try {
                          Navigator.pop(context);
                          print(
                              'Starting download process for episode ${episode.id}');

                          final loadingDialog = showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Téléchargement en cours...'),
                                ],
                              ),
                            ),
                          );

                          try {
                            print('Attempting to download video');
                            final file =
                                await VideoDownloader.downloadVideo(episode);
                            print(
                                'Video downloaded successfully to: ${file.path}');

                            print('Saving to database');
                            await GetIt.I<DatabaseHandler>()
                                .saveDownloadedVideo(episode);
                            print('Saved to database');

                            Navigator.pop(context); // Close loading dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Vidéo téléchargée avec succès')),
                            );
                          } catch (e) {
                            print('Download error: $e');
                            Navigator.pop(context); // Close loading dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        } catch (e) {
                          print('Outer error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                        }
                      },
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
