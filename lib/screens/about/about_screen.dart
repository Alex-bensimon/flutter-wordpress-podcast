// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fwp/models/models.dart';
import 'package:fwp/widgets/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

const causeCommuneDescription =
    "Cause Commune rassemble dans sa grille de programmes les voix pour l’instant disparates des chercheurs et des inventeurs de solutions propres à relever les défis écologiques, techniques, sociaux et économiques du monde d’aujourd’hui. Pour ce faire, sont notamment invités à la rejoindre tous les acteurs du logiciel libre et du numérique, de la culture libre, de la science et de l’éducation, de l’environnement et de la nature qui oeuvrent pour le maintien et la sauvegarde des Biens Communs et pour une société de la Connaissance fondée sur le partage.";
const thinkerviewDescrption =
    "ThinkerView est un groupe indépendant issu d'internet, très diffèrent de la plupart des think-tanks qui sont inféodés à des partis politiques ou des intérêts privés";

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class LinkItem {
  final String title;
  final String link;

  LinkItem(this.title, this.link);

  LinkItem.fromJson(dynamic json)
      : title = json['title']! as String,
        link = json['link']! as String;
}

class _AboutScreenState extends State<AboutScreen> {
  String apptitle = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  List linksItems = [];
  int tapped = 0;
  final app = dotenv.env['APP'];

  Future<void> getInfoPackage() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentPackageName = packageInfo.packageName;

    final response =
        await rootBundle.loadString('assets/data/$currentPackageName.json');
    final Iterable data = await json.decode(response) as Iterable;
    final List<LinkItem> currentLinkItems =
        List<LinkItem>.from(data.map((model) => LinkItem.fromJson(model)));

    setState(() {
      linksItems = currentLinkItems;
      apptitle = packageInfo.appName;
      packageName = currentPackageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    getInfoPackage();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "A propos",
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: renderLinks(),
      ),
    );
  }

  Widget renderLinks() {
    if (linksItems.isEmpty) {
      return const SizedBox.expand();
    }

    return ListView(
      controller: ScrollController(),
      children: [
        ...linksItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              child: Text(
                item.title as String,
              ),
              onPressed: () => launchUrl(Uri.parse(item.link as String)),
            ),
          );
        }),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              apptitle,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              " - ",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              packageName,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Version ",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                version,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                " - ",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                buildNumber,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget renderPodcastDescription() {
    var podcastDescription = "";

    if (app == APP.causecommune.name) {
      podcastDescription = causeCommuneDescription;
    } else if (app == APP.thinkerview.name) {
      podcastDescription = thinkerviewDescrption;
    }

    return Column(
      children: [
        const SizedBox(height: 30),
        Text(
          podcastDescription,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
