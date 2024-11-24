import 'package:flutter/material.dart';
import 'package:vimeo_player_flutter/vimeo_player_flutter.dart';
import 'package:fwp/models/models.dart';
import 'package:fwp/styles/styles.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Episode episode;

  const VideoPlayerScreen({
    Key? key,
    required this.episode,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isLoading = true;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final videoId = _getVimeoVideoId(widget.episode.vimeoUrl);
      print('Video URL: ${widget.episode.vimeoUrl}');
      setState(() {
        _videoId = videoId;
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getVimeoVideoId(String url) {
    final RegExp regExp = RegExp(r'video/(\d+)');
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    throw Exception('Invalid Vimeo URL format');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isAppInDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.episode.title,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_videoId != null && _videoId!.isNotEmpty)
            Expanded(
              child: VimeoPlayer(
                videoId: _videoId!,
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Error loading video'),
                    if (widget.episode.vimeoUrl.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          print('Vimeo URL: ${widget.episode.vimeoUrl}');
                          _initializePlayer();
                        },
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.episode.title,
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.episode.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
