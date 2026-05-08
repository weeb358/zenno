import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'src/router.dart';
import 'src/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  bool firebaseReady = false;

  try {
    // 🔥 Firebase init
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 🔐 App Check (SAFE FOR DEVELOPMENT)
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );

    firebaseReady = true;
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    firebaseReady = false;
    debugPrint("Firebase Init Error: $e");
  }

  // Save Firebase state globally
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

      // Optional: show loading screen if Firebase not ready
      builder: (context, child) {
        if (!firebaseReady) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return child!;
      },

      routerConfig: router,
    );
  }
}