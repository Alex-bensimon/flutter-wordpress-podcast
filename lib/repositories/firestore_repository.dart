import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fwp/models/models.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Episode>> getVideos({required int page}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('vimeo_videos')
          .orderBy('created_time', descending: true)
          .limit(10)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No documents found in vimeo_videos collection');
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Episode(
          id: int.parse(doc.id),
          title: data['name'] ?? '',
          date: data['created_time']?.toDate().toString() ?? '',
          imageUrl: data['thumbnail_url'] ?? '',
          vimeoUrl: data['player_embed_url'] ?? '',
          description: data['description'] ?? '',
          duration: _formatDuration(data['duration']),
        );
      }).toList();
    } catch (e) {
      print('Error fetching videos: $e');
      throw Exception('Error fetching videos: $e');
    }
  }

  String _formatDuration(dynamic durationInSeconds) {
    if (durationInSeconds == null) return '';

    int totalSeconds = 0;
    if (durationInSeconds is int) {
      totalSeconds = durationInSeconds;
    } else if (durationInSeconds is String) {
      totalSeconds = int.tryParse(durationInSeconds) ?? 0;
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final hoursString = hours.toString().padLeft(2, '0');
    final minutesString = minutes.toString().padLeft(2, '0');
    final secondsString = seconds.toString().padLeft(2, '0');

    return '$hoursString:$minutesString:$secondsString';
  }
}
