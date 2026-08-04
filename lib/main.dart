import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/history_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/movie/domain/repositories/movie_repository.dart';
import 'features/movie/data/repositories/movie_repository_impl.dart';
import 'features/movie/presentation/providers/movie_provider.dart';
import 'features/search/presentation/providers/search_provider.dart';
import 'features/tv/presentation/providers/tv_provider.dart';
import 'features/favorite/presentation/providers/favorite_provider.dart';
import 'services/api_service.dart';
import 'pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/boot/presentation/pages/boot_page.dart';
import 'features/boot/presentation/providers/boot_provider.dart';

void main() {
  // Pastikan binding siap secepat mungkin
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => BootProvider()),
        Provider<MovieRepository>(
          create: (_) => MovieRepositoryImpl(
            apiService: ApiService(),
            firestore: FirebaseFirestore.instance,
          ),
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          MovieRepository,
          MovieProvider
        >(
          create: (context) =>
              MovieProvider(repository: context.read<MovieRepository>()),
          update: (context, auth, repository, movieProvider) {
            final provider =
                movieProvider ?? MovieProvider(repository: repository);
            provider.update(auth);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SearchProvider(repository: context.read<MovieRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              TvProvider(repository: context.read<MovieRepository>()),
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          MovieRepository,
          FavoriteProvider
        >(
          create: (context) =>
              FavoriteProvider(repository: context.read<MovieRepository>()),
          update: (context, auth, repository, favoriteProvider) {
            final provider =
                favoriteProvider ?? FavoriteProvider(repository: repository);
            provider.update(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          MovieProvider,
          HistoryProvider
        >(
          create: (_) => HistoryProvider(),
          update: (_, auth, movieProvider, historyProvider) {
            return (historyProvider ?? HistoryProvider())
              ..update(auth, movieProvider);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 1. Load Environment Variables secara paralel
      await dotenv.load(fileName: ".env").catchError((e) {
        debugPrint("[INFO] .env skipped: $e");
      });

      // 2. Initialize Firebase
      if (Firebase.apps.isEmpty) {
        final options = DefaultFirebaseOptions.currentPlatform;
        if (options.apiKey.isNotEmpty) {
          await Firebase.initializeApp(options: options);
        }
      }

      // 3. Firestore Persistence (Non-Web)
      if (!kIsWeb) {
        try {
          FirebaseFirestore.instance.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Init error: $e");
    }
  }

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
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return FutureBuilder(
          future: _initializationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(color: const Color(0xFF0B0E1E));
            }
            return WebResponsiveWrapper(child: child ?? const SizedBox());
          },
        );
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return const LoginPage();
          }
          if (!auth.hasBooted) {
            return BootPage(onComplete: () => auth.setBooted(true));
          }
          return const HomePage();
        },
      ),
    );
  }
}

class WebResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const WebResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Scaffold(
            backgroundColor: const Color(0xFF05070A),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  // Menggunakan resolusi yang lebih kecil & format webp untuk Speed Index
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1477346611705-65d1883cee1e?q=80&w=1000&auto=format,webp&fit=crop',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black87,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9 / 19.5,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0E1E),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: const Color(0xFF1F2235),
                        width: 8,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black54, blurRadius: 20),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
