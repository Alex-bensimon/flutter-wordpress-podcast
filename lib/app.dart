import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fwp/blocs/blocs.dart';
import 'package:fwp/models/models.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:fwp/screens/screens.dart';
import 'package:fwp/styles/styles.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:fwp/service_locator.dart';

class FwpApp extends StatefulWidget {
  const FwpApp({
    Key? key,
  }) : super(key: key);

  @override
  State<FwpApp> createState() => _FwpAppState();
}

class _FwpAppState extends State<FwpApp> with WidgetsBindingObserver {
  List<String> screensTitle = ["Accueil", "Lecteur", "Livres", "A propos"];
  List<Widget> screens = [];
  List<BottomNavigationBarItem> bottomNavigationBarItems = [];
  List<SidebarItem> sidebarItems = [];
  ThemeData lightThemeData = ThemeData();
  ThemeData darkThemeData = ThemeData();
  MacosThemeData darkThemeDataMacOS = MacosThemeData();
  MacosThemeData lightThemeDataMacOS = MacosThemeData();

  final app = dotenv.env['APP'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (app == APP.thinkerview.name) {
      lightThemeData = ligthThemeDataThinkerview;
      darkThemeData = darkThemeDataThinkerview;
      lightThemeDataMacOS = lightThemeDataMacOSThinkerview;
      darkThemeDataMacOS = darkThemeDataMacOSThinkerview;
      screensTitle = ["Accueil", "Lecteur", "Recherche", "Livres", "A propos"];

      screens = const [
        HomeScreen(),
        PlayerScreen(),
        SearchScreen(),
        BooksScreen(),
        AboutScreen()
      ];

      bottomNavigationBarItems = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.house),
          label: screensTitle[0],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.music_note),
          label: screensTitle[1],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: screensTitle[2],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book),
          label: screensTitle[3],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.info),
          label: screensTitle[4],
        )
      ];
    } else if (app == APP.causecommune.name) {
      lightThemeData = ligthThemeDataCauseCommune;
      darkThemeData = darkThemeDataCauseCommune;
      lightThemeDataMacOS = lightThemeDataMacOSCauseCommune;
      darkThemeDataMacOS = darkThemeDataMacOSCauseCommune;
      screensTitle = ["Accueil", "Lecteur", "Recherche", "A propos"];

      screens = const [
        HomeScreen(),
        PlayerScreen(),
        SearchScreen(),
        AboutScreen(),
      ];

      bottomNavigationBarItems = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.house),
          label: screensTitle[0],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.music_note),
          label: screensTitle[1],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: screensTitle[2],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.info),
          label: screensTitle[3],
        )
      ];
    }

    initPlayback();
  }

  List<SidebarItem> getSidebar({required bool isDarkMode}) {
    if (app == APP.thinkerview.name) {
      return [
        SidebarItem(
          leading: MacosIcon(
            CupertinoIcons.home,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          label: Text(
            screensTitle[0],
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        SidebarItem(
          leading: MacosIcon(
            CupertinoIcons.music_note,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          label: Text(
            screensTitle[1],
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        SidebarItem(
          leading: MacosIcon(
            CupertinoIcons.search,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          label: Text(
            screensTitle[2],
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        SidebarItem(
          leading: MacosIcon(
            CupertinoIcons.book,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          label: Text(
            screensTitle[3],
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        SidebarItem(
          leading: MacosIcon(
            CupertinoIcons.info,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          label: Text(
            screensTitle[4],
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: isDarkMode ? Colors.white : Colors.black),
          ),
        ),
      ];
    }
    return [
      SidebarItem(
        leading: MacosIcon(
          CupertinoIcons.home,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        label: Text(
          screensTitle[0],
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      SidebarItem(
        leading: MacosIcon(
          CupertinoIcons.music_note,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        label: Text(
          screensTitle[1],
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      SidebarItem(
        leading: MacosIcon(
          CupertinoIcons.search,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        label: Text(
          screensTitle[2],
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      SidebarItem(
        leading: MacosIcon(
          CupertinoIcons.info,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        label: Text(
          screensTitle[3],
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    ];
  }

  Future<void> initPlayback() async {
    await getIt<PlayerManager>().init();

    final playerManager = getIt<PlayerManager>();
    final episodePlayable =
        await getIt<DatabaseHandler>().getFirstEpisodePlayable();

    if (episodePlayable.audioFileUrl.isNotEmpty) {
      playerManager.loadEpisodePlayable(episodePlayable);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose of the PlayerManager if needed
    getIt<PlayerManager>().dispose();
    // Dispose of the DatabaseHandler
    getIt<DatabaseHandler>().dispose();
    super.dispose(); // Ensure super.dispose() is called
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Clean up when app is closing
      getIt<DatabaseHandler>().dispose();
    }
  }

  String getTitle() {
    if (app == APP.thinkerview.name) {
      return "Thinkerview";
    } else if (app == APP.causecommune.name) {
      return "Cause Commune";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightThemeData,
        darkTheme: darkThemeData,
        home: BlocBuilder<NavigationCubit, int>(
          builder: (_, index) => Scaffold(
            body: IndexedStack(
              index: index,
              children: screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: bottomNavigationBarItems,
              currentIndex: index,
              onTap: (index) => context.read<NavigationCubit>().update(index),
            ),
          ),
        ),
      ),
    );
  }
}
