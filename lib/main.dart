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

void main() async {
  // 1. Pastikan binding siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Environment & Firebase sebelum runApp
  try {
    await dotenv.load(fileName: ".env");

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    if (!kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  } catch (e) {
    debugPrint("Early Init Error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => BootProvider()),
        Provider<MovieRepository>(
          create: (_) =>
              MovieRepositoryImpl(ApiService(), FirebaseFirestore.instance),
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          MovieRepository,
          MovieProvider
        >(
          create: (context) => MovieProvider(context.read<MovieRepository>()),
          update: (context, auth, repository, movieProvider) {
            final provider = movieProvider ?? MovieProvider(repository);
            provider.update(auth);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(context.read<MovieRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TvProvider(context.read<MovieRepository>()),
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          MovieRepository,
          FavoriteProvider
        >(
          create: (context) =>
              FavoriteProvider(context.read<MovieRepository>()),
          update: (context, auth, repository, favoriteProvider) {
            final provider = favoriteProvider ?? FavoriteProvider(repository);
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nyxdex',
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
        return WebResponsiveWrapper(child: child ?? const SizedBox());
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.hasBooted) {
            return BootPage(onComplete: () => auth.setBooted(true));
          }
          if (!auth.isAuthenticated) {
            return const LoginPage();
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
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF14192D), Color(0xFF05070A)],
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
