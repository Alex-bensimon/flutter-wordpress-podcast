import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fwp/app.dart';
import 'package:fwp/blocs/blocs.dart';
import 'package:fwp/repositories/repositories.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<SentryEvent?> beforeSend(SentryEvent event, {dynamic hint}) async {
  final exceptions = event.exceptions;
  bool isHandled = false;

  if (exceptions!.isNotEmpty) {
    for (final exception in exceptions) {
      isHandled = exception.mechanism?.handled ?? isHandled;
    }
  }

  return isHandled ? null : event;
}

Future<void> setupApp() async {
  initializeDateFormatting('fr_FR');

  // Set up HTTP overrides if needed
  HttpOverrides.global = MyHttpOverrides();
}
