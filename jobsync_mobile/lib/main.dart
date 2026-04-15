import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Uri? initialUri;
  try {
    final appLinks = AppLinks();
    initialUri = await appLinks.getInitialLink();
  } catch (_) {}

  final storage = await initializeApp();

  runApp(JobSyncApp(
    storage: storage,
    initialUri: initialUri,
  ));
}
