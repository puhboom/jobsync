import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/sources/local_storage.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/jobs/bloc/jobs_bloc.dart';
import 'features/resumes/bloc/resumes_bloc.dart';
import 'features/subscription/bloc/subscription_bloc.dart';
import 'navigation/main_navigation.dart';

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

Future<void> loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> setDarkMode(bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('dark_mode', enabled);
  themeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;
}

class JobSyncApp extends StatefulWidget {
  final LocalStorage storage;
  final Uri? initialUri;

  const JobSyncApp({
    super.key,
    required this.storage,
    this.initialUri,
  });

  @override
  State<JobSyncApp> createState() => _JobSyncAppState();
}

class _JobSyncAppState extends State<JobSyncApp> with WidgetsBindingObserver {
  StreamSubscription? _uriSubscription;
  AuthBloc? _authBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    if (widget.initialUri != null) {
      _handleUri(widget.initialUri!);
    }

    _uriSubscription = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleUri(uri);
        }
      },
      onError: (err) {
        debugPrint('Error handling incoming link: $err');
      },
    );
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'jobsync' &&
        uri.host == 'oauth' &&
        (uri.path == '/callback' || uri.path == 'callback')) {
      final params = uri.queryParameters;
      final code = params['code'];
      final provider = params['provider'];

      if (code != null && provider != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _authBloc != null) {
            _authBloc!.add(AuthOAuthCallback(
              code: code,
              provider: provider,
            ));
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uriSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) {
        _authBloc = AuthBloc(storage: widget.storage)
          ..add(const AuthCheckRequested());
        return _authBloc!;
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DashboardBloc(),
          ),
          BlocProvider(
            create: (_) => JobsBloc(),
          ),
          BlocProvider(
            create: (_) => ResumesBloc(),
          ),
          BlocProvider(
            create: (_) => SubscriptionBloc(),
          ),
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeMode,
          builder: (context, mode, _) {
            return MaterialApp(
              title: AppConstants.appName,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              debugShowCheckedModeBanner: false,
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthInitial || state is AuthLoading) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is AuthAuthenticated) {
                    return const MainNavigation();
                  }

                  return const LoginScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<LocalStorage> initializeApp() async {
  await Hive.initFlutter();

  await Hive.openBox(AppConstants.jobsBox);
  await Hive.openBox(AppConstants.resumesBox);
  await Hive.openBox(AppConstants.pendingOpsBox);
  await Hive.openBox(AppConstants.settingsBox);

  await loadThemePreference();

  return LocalStorage();
}
