import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';
import 'package:fwp/repositories/audio_handler_repository.dart';
import 'package:fwp/repositories/player_manager_repository.dart';
import 'package:fwp/repositories/database_handler.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register DatabaseHandler
  getIt.registerSingleton<DatabaseHandler>(DatabaseHandler());

  // Initialize AudioHandler and register it
  final audioHandler = await initAudioService();
  getIt.registerSingleton<AudioHandler>(audioHandler);

  // Register PlayerManager
  getIt.registerLazySingleton<PlayerManager>(() => PlayerManager());
}
