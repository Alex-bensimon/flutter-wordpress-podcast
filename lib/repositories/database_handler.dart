import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fwp/models/episode_model.dart';
import 'package:fwp/services/video_downloader.dart';

class DatabaseHandler {
  static const String tablename = "videos";
  static const String userTableName = "users";
  static const String databaseName = "videos.db";
  Database? _db;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, databaseName);

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            '''CREATE TABLE $tablename (
              id INTEGER PRIMARY KEY,
              title TEXT,
              date TEXT,
              vimeoUrl TEXT,
              articleUrl TEXT,
              description TEXT,
              imageUrl TEXT,
              lastPosition INTEGER,
              duration TEXT
            )''',
          );

          await db.execute(
            '''CREATE TABLE $userTableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE,
              lastLoginDate TEXT
            )''',
          );
        },
      );
      _initialized = true;
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
    }
    _initialized = false;
  }

  Future<Database> get database async {
    if (!_initialized) await init();
    return _db!;
  }

  Future<Episode> getLastWatchedVideo() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablename,
      where: 'vimeoUrl IS NOT NULL AND vimeoUrl != ""',
      orderBy: 'lastPosition DESC',
      limit: 1,
    );

    return maps.isEmpty
        ? Episode.empty()
        : Episode.fromJson(maps.first['id'], jsonEncode(maps.first));
  }

  Future<void> saveVideoProgress(Episode episode, int position) async {
    final db = await database;
    await db.insert(
      tablename,
      {
        'id': episode.id,
        'title': episode.title,
        'date': episode.date,
        'vimeoUrl': episode.vimeoUrl,
        'description': episode.description,
        'imageUrl': episode.imageUrl,
        'lastPosition': position,
        'duration': episode.duration,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveUserLogin(String email) async {
    final db = await database;
    await db.insert(
      userTableName,
      {
        'email': email,
        'lastLoginDate': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveDownloadedVideo(Episode episode) async {
    final db = await database;
    await db.insert(
      'downloaded_videos',
      {
        'id': episode.id,
        'title': episode.title,
        'download_date': DateTime.now().toIso8601String(),
        'file_path':
            '${await VideoDownloader.getVideoDirectory()}/${episode.id}.mp4',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isVideoDownloaded(int videoId) async {
    final db = await database;
    final result = await db.query(
      'downloaded_videos',
      where: 'id = ?',
      whereArgs: [videoId],
    );
    return result.isNotEmpty;
  }

  Future<List<Episode>> getDownloadedVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('downloaded_videos');

    return maps
        .map((map) => Episode(
              id: map['id'] as int,
              title: map['title'] as String,
              date: map['download_date'] as String,
              imageUrl: '',
              vimeoUrl: map['file_path'] as String,
              description: '',
              duration: '',
            ))
        .toList();
  }
}
