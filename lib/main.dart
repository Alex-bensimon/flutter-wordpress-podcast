import 'package:flutter/material.dart';
import 'package:fwp/setup_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fwp/firebase_options.dart';
import 'package:fwp/app.dart';
import 'package:fwp/screens/auth/auth_screen.dart';
import 'package:fwp/service_locator.dart';
import 'package:fwp/repositories/database_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fwp/blocs/navigation/navigation_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load .env file first
    await dotenv.load();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize services
    await setupServiceLocator();

    // Initialize database first
    await getIt<DatabaseHandler>().init();

    await setupApp();
  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<NavigationCubit>(
                    create: (context) => NavigationCubit(),
                  ),
                ],
                child: FwpApp(),
              );
            } else {
              return AuthScreen();
            }
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
