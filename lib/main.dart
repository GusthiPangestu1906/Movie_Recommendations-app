import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/movie_provider.dart';
import 'providers/history_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables (Gunakan try-catch spesifik agar tidak menghentikan Firebase)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Dotenv Load Error: $e (Abaikan jika di Web dan API Key sudah di-hardcode)");
    }

    // Initialize Firebase secara aman
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Firestore Persistence (Hanya untuk Mobile)
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.windows &&
        defaultTargetPlatform != TargetPlatform.linux &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MovieProvider>(
          create: (_) => MovieProvider(),
          update: (_, auth, movieProvider) => movieProvider!..update(auth),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, MovieProvider, HistoryProvider>(
          create: (_) => HistoryProvider(),
          update: (_, auth, movieProvider, historyProvider) =>
              historyProvider!..update(auth, movieProvider),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Movies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0E1E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6AC4),
          brightness: Brightness.dark,
          primary: const Color(0xFF5C6AC4),
          secondary: const Color(0xFF9FA8DA),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      builder: (context, child) {
        return WebResponsiveWrapper(child: child!);
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) => auth.isAuthenticated ? const HomePage() : const LoginPage(),
      ),
    );
  }
}

class WebResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const WebResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Jika bukan Web, langsung tampilkan child
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint: jika lebar layar > 600px (Tablet/Laptop)
        if (constraints.maxWidth > 600) {
          return Container(
            color: Colors.black, // Background luar "HP"
            child: Center(
              child: AspectRatio(
                aspectRatio: 9 / 19, // Rasio layar HP modern
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E1E),
                    borderRadius: BorderRadius.circular(40), // Radius frame HP
                    border: Border.all(color: Colors.grey.shade800, width: 8), // Frame luar
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        }
        // Jika di HP (lebar < 600px), tampilkan full screen biasa
        return child;
      },
    );
  }
}
