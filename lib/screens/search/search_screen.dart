import 'package:flutter/material.dart';
import 'package:fwp/models/models.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:fwp/styles/styles.dart';
import 'package:fwp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode focusNode = FocusNode();
  final FirestoreRepository firestoreRepository = FirestoreRepository();
  List<Episode> episodes = [];
  String query = "";
  bool hasError = false;
  bool hasUserStartedSearching = false;
  bool isLoading = false;
  bool isSearchViewClicked = false;

  Future<void> search(String searchText) async {
    if (searchText.isEmpty) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Convert search text to lowercase for case-insensitive search
      final searchLower = searchText.toLowerCase();

      // Get all documents from Firestore
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vimeo_videos')
          .orderBy('created_time', descending: true)
          .get(); // Removed the limit to get all documents

      // Filter and map documents that contain the search text
      final searchEpisodes = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] as String).toLowerCase();
        return name.contains(searchLower);
      }).map((doc) {
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

      setState(() {
        isLoading = false;
        hasUserStartedSearching = true;
        episodes = searchEpisodes;
      });
    } catch (error) {
      print('Search error: $error');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  String _formatDuration(dynamic duration) {
    if (duration == null) return '';
    final minutes = (duration / 60).floor();
    final seconds = (duration % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          isSearchViewClicked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isAppInDarkMode(context);

    return AdaptiveScaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: renderTitle(isDarkMode: isDarkMode),
        actions: <Widget>[
          IconButton(
            icon: isSearchViewClicked
                ? Icon(
                    Icons.close,
                    color: isDarkMode ? Colors.white : Colors.black,
                  )
                : const SizedBox.shrink(),
            onPressed: () {
              setState(() {
                if (isSearchViewClicked) {
                  isSearchViewClicked = false;
                } else {
                  isSearchViewClicked = true;
                }
              });
            },
          )
        ],
      ),
      body: episodes.isNotEmpty ? renderResults() : renderNoSearchResult(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isSearchViewClicked = true;
          });
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget renderTitle({required bool isDarkMode}) {
    if (!isSearchViewClicked &&
        episodes.isNotEmpty &&
        hasUserStartedSearching) {
      if (query.isEmpty) {
        return Text(
          'Résultats',
          style: Theme.of(context).textTheme.headline6,
        );
      }

      return Text(
        'Résultats pour "$query"',
        style: Theme.of(context).textTheme.headline6,
      );
    }

    if (isSearchViewClicked) {
      return TextField(
        focusNode: focusNode,
        onSubmitted: (value) {
          isSearchViewClicked = false;
          setState(() {
            query = value;
          });
          search(value);
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Chercher',
          icon: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              setState(() {
                isSearchViewClicked = false;
              });
            },
          ),
        ),
        autofocus: true,
      );
    }

    return Text(
      "Chercher un épisode",
      style: Theme.of(context).textTheme.headline6,
    );
  }

  Widget renderNoSearchResult() {
    if (hasUserStartedSearching) {
      return const Center(
        child: Text(
          'Aucun résultat',
          style: TextStyle(fontSize: 24),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget renderResults() {
    if (hasError) {
      return const Center(child: Text("Une erreur est survenue"));
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (context, index) => EpisodeCard(
        imageUrl: episodes[index].imageUrl,
        title: episodes[index].title,
        vimeoUrl: episodes[index].vimeoUrl,
        duration: episodes[index].duration,
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
                EpisodeOptions(episode: episodes[index]),
          );
        },
      ),
    );
  }
}
