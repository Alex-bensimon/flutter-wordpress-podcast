import 'package:flutter/material.dart';
import 'package:fwp/models/models.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:fwp/styles/styles.dart';
import 'package:fwp/widgets/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:macos_ui/macos_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreRepository firestoreRepository = FirestoreRepository();
  final _pagingController = PagingController<int, Episode>(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final episodes = await firestoreRepository.getVideos(page: pageKey);

      if (episodes.isEmpty && pageKey == 1) {
        _pagingController.error = 'No videos found';
        return;
      }

      final isLastPage = episodes.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(episodes);
      } else {
        _pagingController.appendPage(episodes, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: PagedListView<int, Episode>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Episode>(
            itemBuilder: (context, episode, index) => EpisodeCard(
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
            ),
          ),
        ),
      ),
    );
  }
}
