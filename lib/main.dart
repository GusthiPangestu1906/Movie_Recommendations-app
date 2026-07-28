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
import 'widgets/particle_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Load Environment Variables
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("[SUCCESS] .env loaded");
    } catch (e) {
      debugPrint("[CRITICAL] Failed to load .env: $e");
    }

    // 2. Validasi Konfigurasi (Mencegah inisialisasi dengan data kosong)
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey.isEmpty) {
      throw Exception("Firebase API Key is empty. Check your .env file.");
    }

    // 3. Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
      debugPrint("[SUCCESS] Firebase initialized");
    }

    // 4. Firestore Persistence
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.windows &&
        defaultTargetPlatform != TargetPlatform.linux &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
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
          ChangeNotifierProxyProvider2<AuthProvider, MovieProvider,
              HistoryProvider>(
            create: (_) => HistoryProvider(),
            update: (_, auth, movieProvider, historyProvider) =>
                historyProvider!..update(auth, movieProvider),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint("CRITICAL INITIALIZATION ERROR: $e");
    // Tampilkan error di layar jika gagal inisialisasi
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF0B0E1E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "App Configuration Error:\n$e\n\nPastikan file .env sudah benar dan ada di root project.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ),
      ),
    ));
  }
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
          headlineMedium:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      builder: (context, child) {
        return WebResponsiveWrapper(child: child!);
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) =>
            auth.isAuthenticated ? const HomePage() : const LoginPage(),
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
          return Scaffold(
            backgroundColor: const Color(0xFF05070A),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1477346611705-65d1883cee1e?q=80&w=2070&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
              ),
              child: Stack(
                children: [
                  // --- Decorative Background Elements ---
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4A56E2).withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -150,
                    left: -100,
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF5C6AC4).withValues(alpha: 0.05),
                      ),
                    ),
                  ),

                  // --- Top Left: App Identity ---
                  Positioned(
                    top: 40,
                    left: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/Group 3.png',
                              width: 60,
                              height: 60,
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MY MOVIES',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'CINEMATIC UNIVERSE',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- Top Right: Navigation & Real-time Info ---
                  Positioned(
                    top: 40,
                    right: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            _buildWebButton(Icons.help_outline, 'Support'),
                            const SizedBox(width: 15),
                            _buildWebButton(Icons.info_outline, 'About'),
                            const SizedBox(width: 15),
                            const Icon(Icons.notifications_none, color: Colors.white24),
                          ],
                        ),
                        const SizedBox(height: 20),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final now = DateTime.now();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  "${now.day}/${now.month}/${now.year}",
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // --- Left Side: Social Bar ---
                  Positioned(
                    left: 40,
                    top: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      children: [
                        _buildSocialIcon(Icons.camera_alt_outlined),
                        const SizedBox(height: 20),
                        _buildSocialIcon(Icons.facebook_outlined),
                        const SizedBox(height: 20),
                        _buildSocialIcon(Icons.alternate_email),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: 1,
                          height: 100,
                          color: Colors.white10,
                        ),
                      ],
                    ),
                  ),

                  // --- Right Side: Trending Ticker ---
                  Positioned(
                    right: 40,
                    top: MediaQuery.of(context).size.height * 0.4,
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TRENDING NOW',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 15),
                          _buildTrendingItem('The Dark Knight', '01'),
                          _buildTrendingItem('Inception', '02'),
                          _buildTrendingItem('Interstellar', '03'),
                          _buildTrendingItem('The Prestige', '04'),
                        ],
                      ),
                    ),
                  ),

                  // --- Bottom Left: System Status ---
                  Positioned(
                    bottom: 40,
                    left: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SYSTEM STATUS',
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                    radius: 4, backgroundColor: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'SERVERS OPERATIONAL',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  // --- Bottom Right: Mobile QR ---
                  Positioned(
                    bottom: 40,
                    right: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'SCAN TO SYNC',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Get Mobile App',
                                  style: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 15),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: const Icon(Icons.qr_code_2,
                                  color: Colors.white54, size: 50),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- THE MAIN SMARTPHONE FRAME ---
                  Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 19.5, // Rasio layar HP modern lebih tinggi
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0E1E),
                          borderRadius: BorderRadius.circular(48), // Lebih rounded
                          border: Border.all(
                            color: const Color(0xFF1F2235),
                            width: 12,
                          ), // Frame fisik HP
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.15),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(20, 20),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(38),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // Jika di HP (lebar < 600px), tampilkan full screen biasa
        return child;
      },
    );
  }

  Widget _buildWebButton(IconData icon, String label) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white24, size: 20),
      ),
    );
  }

  Widget _buildTrendingItem(String title, String rank) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(width: 12),
          Text(
            rank,
            style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
