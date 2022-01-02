import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fwp/models/models.dart';
import 'package:html_unescape/html_unescape.dart';

class Episode {
  final int id;
  final String title;
  final String date;
  final String audioFileUrl;
  final String imageUrl;

  Episode({
    required this.id,
    required this.audioFileUrl,
    required this.date,
    required this.title,
    required this.imageUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    final app = dotenv.env['APP'];
    final unescape = HtmlUnescape();

    try {
      if (APP.thinkerview.name == app) {
        return Episode(
          id: json['id'] as int,
          title: json['title']['rendered'] as String,
          date: json['date'] as String,
          audioFileUrl: json['meta']['audio_file'] as String,
          imageUrl: json['episode_featured_image'] as String,
        );
      } else if (APP.causecommune.name == app) {
        return Episode(
          id: json['id'] as int,
          title: unescape.convert(json['title']['rendered'] as String),
          date: json['date'] as String,
          audioFileUrl: json['meta']['audio_file'] as String,
          imageUrl: json['episode_player_image'] as String,
        );
      } else {
        throw "Incorrect app env variable";
      }
    } catch (e) {
      return Episode(
        id: 0,
        audioFileUrl: "",
        date: "",
        title: "",
        imageUrl: "",
      );
    }
  }
}
