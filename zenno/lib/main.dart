import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'src/router.dart';
import 'src/providers.dart';
import 'widgets/gaming_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseReady = ref.watch(firebaseReadyProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Zenno',
      theme: _buildSteamTheme(),
      builder: (context, child) {
        if (!firebaseReady) {
          return const Scaffold(
            backgroundColor: kSteamBg,
            body: Center(
              child: CircularProgressIndicator(color: kSteamAccent),
            ),
          );
        }
        return child!;
      },
      routerConfig: router,
    );
  }

  ThemeData _buildSteamTheme() {
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
}
