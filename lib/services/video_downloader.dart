import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fwp/models/models.dart';
import 'dart:convert';

class VideoDownloader {
  static Future<String> getVideoDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${directory.path}/secured_videos');
    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }
    return videoDir.path;
  }

  static String _getVimeoVideoId(String url) {
    final RegExp regExp = RegExp(r'(?:video/|vimeo\.com/)(\d+)');
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      print('Extracted video ID: ${match.group(1)}');
      return match.group(1)!;
    }
    throw Exception('Invalid Vimeo URL format: $url');
  }

  static Future<File> downloadVideo(Episode episode) async {
    print('Starting download for episode: ${episode.id}');
    print('Vimeo URL: ${episode.vimeoUrl}');

    final videoDir = await getVideoDirectory();
    final videoFile = File('$videoDir/${episode.id}.mp4');

    if (await videoFile.exists()) {
      print('Video already exists at: ${videoFile.path}');
      return videoFile;
    }

    try {
      final videoId = _getVimeoVideoId(episode.vimeoUrl);
      print('Extracted video ID: $videoId');

      final vimeoUrl = 'https://player.vimeo.com/video/$videoId/config';
      print('Requesting config from: $vimeoUrl');

      final response = await http.get(Uri.parse(vimeoUrl));
      print('Config response status: ${response.statusCode}');
      print('Config response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to get video URL: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      print('Parsed config data: $data');

      final downloadUrl = data['request']['files']['progressive'][0]['url'];
      print('Download URL: $downloadUrl');

      final videoResponse = await http.get(Uri.parse(downloadUrl));
      print('Video download status: ${videoResponse.statusCode}');

      if (videoResponse.statusCode == 200) {
        await videoFile.writeAsBytes(videoResponse.bodyBytes);
        print('Video saved to: ${videoFile.path}');
        return videoFile;
      } else {
        throw Exception(
            'Failed to download video: ${videoResponse.statusCode}');
      }
    } catch (e) {
      print('Error during download: $e');
      throw Exception('Download failed: $e');
    }
  }

  static Future<bool> isVideoDownloaded(Episode episode) async {
    final videoDir = await getVideoDirectory();
    final videoFile = File('$videoDir/${episode.id}.mp4');
    return await videoFile.exists();
  }
}
