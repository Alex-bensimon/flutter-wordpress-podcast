import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fwp/models/models.dart';
import 'package:fwp/widgets/widgets.dart';

class CategoryVideosScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const CategoryVideosScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(categoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vimeo_videos')
            .where('category_ids', arrayContains: categoryId)
            .orderBy('created_time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final videos = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final videoData = videos[index].data() as Map<String, dynamic>;
              final episode = Episode(
                id: int.parse(videos[index].id),
                title: videoData['name'] ?? '',
                date: videoData['created_time']?.toDate().toString() ?? '',
                imageUrl: videoData['thumbnail_url'] ?? '',
                vimeoUrl: videoData['player_embed_url'] ?? '',
                description: videoData['description'] ?? '',
                duration: videoData['duration']?.toString() ?? '',
              );

              return EpisodeCard(
                imageUrl: episode.imageUrl,
                title: episode.title,
                vimeoUrl: episode.vimeoUrl,
                duration: episode.duration,
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
                        EpisodeOptions(episode: episode),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
