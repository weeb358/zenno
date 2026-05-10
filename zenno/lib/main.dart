// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'src/router.dart';
import 'src/providers.dart';
import 'src/translations.dart';
import 'src/services/local_notification_service.dart';
import 'src/services/sound_service.dart';
import 'widgets/gaming_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService.init();

  final container = ProviderContainer();
  bool firebaseReady = false;

  try {
    FirebaseApp firebaseApp;
    try {
      firebaseApp = Firebase.app();
    } on FirebaseException {
      try {
        if (kIsWeb) {
          firebaseApp = await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } else {
          firebaseApp = await Firebase.initializeApp();
        }
      } on FirebaseException {
        firebaseApp = await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    }

    final database = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
    );
    database.setPersistenceEnabled(true);

    firebaseReady = true;
    debugPrint('Firebase initialized');
  } catch (e) {
    firebaseReady = false;
    debugPrint('Firebase Init Error: $e');
  }

  container.read(firebaseReadyProvider.notifier).state = firebaseReady;

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

Locale _languageToLocale(String language) {
  switch (language.toLowerCase()) {
    case 'spanish':  return const Locale('es');
    case 'french':   return const Locale('fr');
    case 'german':   return const Locale('de');
    default:         return const Locale('en');
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Track notification IDs we've already shown so we don't re-fire them.
  final Set<String> _shownIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSettings();
    });
  }

  void _syncSettings() {
    // Sync Firebase settings → appSettingsProvider on login/real-time update.
    ref.listenManual(userSettingsStreamProvider, (_, next) {
      next.whenData((map) {
        if (map.isNotEmpty) {
          ref.read(appSettingsProvider.notifier).update(AppSettings.fromMap(map));
        }
      });
    });

    // Reset settings to defaults on logout.
    ref.listenManual(authStateChangesProvider, (_, next) {
      if (next.value == null) {
        ref.read(appSettingsProvider.notifier).reset();
        SoundService.stop();
      }
    });

    // Toggle background sound when appSound setting changes.
    ref.listenManual(appSettingsProvider, (previous, next) {
      if (previous?.appSound != next.appSound) {
        SoundService.toggle(next.appSound);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseReady = ref.watch(firebaseReadyProvider);
    final settings = ref.watch(appSettingsProvider);

    // Update translation language before building the tree.
    setAppLanguage(settings.language);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Zenno',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _languageToLocale(settings.language),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
      ],
      builder: (context, child) {
        if (!firebaseReady) {
          return const Scaffold(
            backgroundColor: kSteamBg,
            body: Center(child: CircularProgressIndicator(color: kSteamAccent)),
          );
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: _NotificationWatcher(
            shownIds: _shownIds,
            notificationsEnabled: settings.notifications,
            child: child!,
          ),
        );
      },
      routerConfig: router,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kSteamBg,
      colorScheme: const ColorScheme.dark(
        primary: kSteamAccent,
        secondary: kSteamGreen,
        surface: kSteamDark,
        error: kSteamRed,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(
        const TextTheme(
          bodyMedium: TextStyle(color: kSteamText),
          bodySmall: TextStyle(color: kSteamSubtext),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: kSteamDark,
        foregroundColor: kSteamAccent,
        titleTextStyle: GoogleFonts.rajdhani(
          color: kSteamAccent,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 3,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? kSteamAccent : kSteamSubtext),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? kSteamAccent.withValues(alpha: 0.5)
                : kSteamMed),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kSteamDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: kSteamMed),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kSteamDark,
        contentTextStyle: GoogleFonts.rajdhani(color: kSteamText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: kSteamAccent),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFEEF2F6),
      colorScheme: ColorScheme.light(
        primary: kSteamAccent,
        secondary: kSteamGreen,
        surface: Colors.white,
        error: kSteamRed,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(
        const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1b2838)),
          bodySmall: TextStyle(color: Color(0xFF4a6070)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1b2838),
        foregroundColor: kSteamAccent,
        titleTextStyle: GoogleFonts.rajdhani(
          color: kSteamAccent,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 3,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? kSteamAccent : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? kSteamAccent.withValues(alpha: 0.5)
                : Colors.grey.shade300),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1b2838),
        contentTextStyle: GoogleFonts.rajdhani(color: kSteamText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        behavior: SnackBarBehavior.floating,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey.shade300,
    );
  }
}

/// Watches the Firebase notifications stream and fires a local notification
/// whenever a new entry appears (while notifications are enabled).
class _NotificationWatcher extends ConsumerStatefulWidget {
  final Set<String> shownIds;
  final bool notificationsEnabled;
  final Widget child;

  const _NotificationWatcher({
    required this.shownIds,
    required this.notificationsEnabled,
    required this.child,
  });

  @override
  ConsumerState<_NotificationWatcher> createState() => _NotificationWatcherState();
}

class _NotificationWatcherState extends ConsumerState<_NotificationWatcher> {
  @override
  Widget build(BuildContext context) {
    if (widget.notificationsEnabled) {
      ref.listen(notificationsStreamProvider, (_, next) {
        next.whenData((list) {
          for (final n in list) {
            final id = n['id']?.toString() ?? '';
            if (id.isNotEmpty && !widget.shownIds.contains(id)) {
              widget.shownIds.add(id);
              final title = n['title']?.toString() ?? 'Zenno';
              final body = n['message']?.toString() ?? '';
              LocalNotificationService.showNotification(id.hashCode, title, body);
            }
          }
        });
      });
    }
    return widget.child;
  }
}
