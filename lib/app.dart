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
  List<String> screensTitle = [
    "Accueil",
    "Recherche",
    "Catégories",
    "A propos"
  ];
  List<Widget> screens = [];
  List<BottomNavigationBarItem> bottomNavigationBarItems = [];
  ThemeData lightThemeData = ThemeData();
  ThemeData darkThemeData = ThemeData();

  final app = dotenv.env['APP'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (app == APP.thinkerview.name) {
      lightThemeData = ligthThemeDataThinkerview;
      darkThemeData = darkThemeDataThinkerview;
      screensTitle = ["Accueil", "Recherche", "Catégories", "BD", "A propos"];

      screens = const [
        HomeScreen(),
        SearchScreen(),
        CategoriesScreen(),
        ComicsScreen(),
        AboutScreen()
      ];

      bottomNavigationBarItems = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.house),
          label: screensTitle[0],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: screensTitle[1],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.category),
          label: screensTitle[2],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book),
          label: screensTitle[3],
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.info),
          label: screensTitle[4],
        ),
      ];
    }
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
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: BlocBuilder<NavigationCubit, int>(
          builder: (_, index) => IndexedStack(
            index: index,
            children: screens,
          ),
        ),
        bottomNavigationBar: BlocBuilder<NavigationCubit, int>(
          builder: (context, index) => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: bottomNavigationBarItems,
            currentIndex: index,
            onTap: (index) => context.read<NavigationCubit>().update(index),
          ),
        ),
      ),
    );
  }
}
