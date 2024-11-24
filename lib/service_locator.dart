import 'package:get_it/get_it.dart';
import 'package:audio_service/audio_service.dart';
import 'package:fwp/repositories/database_handler.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register DatabaseHandler
  getIt.registerSingleton<DatabaseHandler>(DatabaseHandler());
}
