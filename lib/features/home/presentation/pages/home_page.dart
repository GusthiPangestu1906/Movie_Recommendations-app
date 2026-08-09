import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/connectivity_provider.dart';
import '../../../../pages/search_page.dart';
import '../../../../pages/tv_page.dart';
import '../../../../pages/history_page.dart';
import '../../../../pages/movie_list_screen.dart';
import '../providers/home_provider.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/offline_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _pageController = PageController(initialPage: homeProvider.currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _getPages(bool isDramaMode) {
    return [
      isDramaMode ? const TvPage() : const MovieListScreen(),
      const SearchPage(),
      const HistoryPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final isDramaMode = homeProvider.isDramaMode;
    final currentIndex = homeProvider.currentIndex;
    final pages = _getPages(isDramaMode);

    return Scaffold(
      appBar: HomeAppBar(currentIndex: currentIndex),
      drawer: const HomeDrawer(),
      body: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, _) {
          return Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  homeProvider.setIndex(index);
                },
                children: pages,
              ),
              if (!connectivity.isOnline) const OfflineOverlay(),
            ],
          );
        },
      ),
      bottomNavigationBar: HomeBottomNav(
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
