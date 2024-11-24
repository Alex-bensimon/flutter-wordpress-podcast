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
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // User is logged in
              return FwpApp();
            } else {
              // User is not logged in
              return AuthScreen();
            }
          } else {
            // Waiting for connection
            return Scaffold(
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
