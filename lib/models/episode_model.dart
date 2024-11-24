// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fwp/models/models.dart';
import 'package:html_unescape/html_unescape.dart';

class Episode {
  final int id;
  final String title;
  final String date;
  final String imageUrl;
  final String vimeoUrl;
  final String description;
  final String duration;

  Episode({
    required this.id,
    required this.date,
    required this.title,
    required this.imageUrl,
    required this.vimeoUrl,
    required this.description,
    this.duration = '',
  });

  factory Episode.fromJson(Map<String, dynamic> json, String app) {
    final unescape = HtmlUnescape();

    String formatDuration(dynamic duration) {
      if (duration == null) return '';
      try {
        final seconds = int.parse(duration.toString());
        final hours = seconds ~/ 3600;
        final minutes = (seconds % 3600) ~/ 60;
        final remainingSeconds = seconds % 60;

        return '${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${remainingSeconds.toString().padLeft(2, '0')}';
      } catch (e) {
        return '';
      }
    }

    try {
      final int id = json['id'] as int;
      final String title =
          unescape.convert(json['title']['rendered'] as String);
      final String date = json['date'] as String;
      final String description = json["content"]["rendered"] as String;
      String imageUrl = "";
      String vimeoUrl = "";

      if (APP.thinkerview.name == app) {
        imageUrl = json['episode_featured_image'] as String;
        try {
          final rendered = json['content']['rendered'] as String;
          final regexp = RegExp(r'vimeo\.com\/(\d+)(?:\/([a-zA-Z0-9]+))?');
          final match = regexp.firstMatch(rendered);
          if (match != null) {
            vimeoUrl = match.group(0) ?? '';
            if (kDebugMode) {
              print('Found Vimeo URL: $vimeoUrl');
            }
          }
        } catch (error) {
          if (kDebugMode) {
            print('Error parsing Vimeo URL: $error');
          }
        }
      } else if (APP.causecommune.name == app) {
        imageUrl = json['episode_player_image'] as String;
      }

      return Episode(
        id: id,
        title: title,
        date: date,
        imageUrl: imageUrl,
        vimeoUrl: vimeoUrl,
        description: description,
        duration: formatDuration(json['duration']),
      );
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return Episode(
        id: 0,
        date: "",
        title: "",
        imageUrl: "",
        vimeoUrl: "",
        description: "",
        duration: "",
      );
    }
  }

  factory Episode.fromVimeoJson(Map<String, dynamic> json) {
    return Episode(
      id: int.parse(json['uri'].split('/').last),
      title: json['name'] ?? '',
      date: json['created_time'] ?? '',
      imageUrl: json['pictures']['sizes'].firstWhere(
            (size) => size['width'] >= 640,
            orElse: () => json['pictures']['sizes'].last,
          )['link'] ??
          '',
      vimeoUrl: json['link'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration']?.toString() ?? '',
    );
  }

  factory Episode.empty() => Episode(
        id: -1,
        title: '',
        date: '',
        imageUrl: '',
        vimeoUrl: '',
        description: '',
        duration: '',
      );

  @override
  String toString() {
    return 'Episode{id: $id, date: $date, imageUrl: $imageUrl, title: $title, description: $description}';
  }
}
