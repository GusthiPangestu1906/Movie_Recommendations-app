import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';

class HomeBottomNav extends StatelessWidget {
  final Function(int)? onTap;

  const HomeBottomNav({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final isDramaMode = homeProvider.isDramaMode;
    final currentIndex = homeProvider.currentIndex;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: const Color(0xFF0B0E1E),
        selectedItemColor: const Color(0xFF5C6AC4),
        unselectedItemColor: Colors.white30,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (index) {
          if (onTap != null) {
            onTap!(index);
          } else {
            homeProvider.setIndex(index);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(isDramaMode ? Icons.tv : Icons.movie_filter),
            ),
            label: isDramaMode ? 'Drama' : 'Movies',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.search),
            ),
            label: 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.history),
            ),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
