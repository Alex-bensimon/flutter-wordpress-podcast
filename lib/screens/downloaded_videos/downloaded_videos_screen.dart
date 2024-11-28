import 'package:flutter/material.dart';
import 'package:fwp/models/models.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:fwp/widgets/widgets.dart';
import 'package:fwp/services/video_downloader.dart';
import 'package:get_it/get_it.dart';

class DownloadedVideosScreen extends StatefulWidget {
  const DownloadedVideosScreen({Key? key}) : super(key: key);

  @override
  State<DownloadedVideosScreen> createState() => _DownloadedVideosScreenState();
}

class _DownloadedVideosScreenState extends State<DownloadedVideosScreen> {
  List<Episode> _downloadedEpisodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedVideos();
  }

  Future<void> _loadDownloadedVideos() async {
    try {
      final episodes = await GetIt.I<DatabaseHandler>().getDownloadedVideos();
      setState(() {
        _downloadedEpisodes = episodes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Vidéos téléchargées'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloadedEpisodes.isEmpty
              ? const Center(child: Text('Aucune vidéo téléchargée'))
              : ListView.builder(
                  itemCount: _downloadedEpisodes.length,
                  itemBuilder: (context, index) => EpisodeCard(
                    imageUrl: _downloadedEpisodes[index].imageUrl,
                    title: _downloadedEpisodes[index].title,
                    vimeoUrl: _downloadedEpisodes[index].vimeoUrl,
                    duration: _downloadedEpisodes[index].duration,
                    onPressed: () {
                      showModalBottomSheet<void>(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        context: context,
                        builder: (BuildContext context) =>
                            EpisodeOptions(episode: _downloadedEpisodes[index]),
                      );
                    },
                  ),
                ),
    );
  }
}
