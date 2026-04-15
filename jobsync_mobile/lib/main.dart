import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle deep link if app was launched with OAuth callback
  Uri? initialUri;
  try {
    initialUri = await getInitialUri();
  } catch (_) {
    // Ignore errors getting initial URI
  }

  // Initialize app (Hive, storage)
  final storage = await initializeApp();

  runApp(JobSyncApp(
    storage: storage,
    initialUri: initialUri,
  ));
}