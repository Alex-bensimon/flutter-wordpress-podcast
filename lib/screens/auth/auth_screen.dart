// lib/screens/auth/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fwp/styles/styles.dart';
import 'package:fwp/repositories/database_handler.dart';
import 'package:fwp/service_locator.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLogin = true;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (isValid != null && isValid) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState?.save();

      try {
        if (isLogin) {
          // Log user in
          await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
        } else {
          // Register user
          await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
        }

        // Save user login information to database
        await getIt<DatabaseHandler>().saveUserLogin(email.trim());
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred, please check your credentials.';
        if (e.message != null) {
          message = e.message!;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isAppInDarkMode(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: getBackgroundColor(isDarkMode: isDarkMode),
            elevation: 8.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLogin ? 'Login' : 'Sign Up',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        key: ValueKey('email'),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        onSaved: (value) {
                          email = value ?? '';
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('password'),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        onSaved: (value) {
                          password = value ?? '';
                        },
                      ),
                      const SizedBox(height: 20),
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            textStyle: Theme.of(context).textTheme.button,
                          ),
                          onPressed: _trySubmit,
                          child: Text(isLogin ? 'Login' : 'Sign Up'),
                        ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(
                          isLogin
                              ? 'Create an account'
                              : 'I already have an account',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
