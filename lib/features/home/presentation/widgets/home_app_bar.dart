import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/movie_provider.dart';
import '../providers/home_provider.dart';
import 'filter_sheet.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;

  const HomeAppBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final isDramaMode = homeProvider.isDramaMode;

    String title = isDramaMode ? 'Drama Universe' : 'Movie Universe';
    PreferredSizeWidget? bottom;

    if (currentIndex == 1) {
      title = isDramaMode ? 'Search Dramas' : 'Search Movies';
      bottom = PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => movieProvider.search(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: isDramaMode
                        ? 'Search Drama & TV...'
                        : 'Search Movies...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    prefixIcon: const Icon(Icons.search, color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5C6AC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isDramaMode ? Icons.flag_outlined : Icons.tune,
                    color: const Color(0xFF5C6AC4),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showFilterPicker(context, isDramaMode);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else if (currentIndex == 2) {
      title = isDramaMode ? 'Drama History' : 'Movie History';
    }

    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.menu_open),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: [
        IconButton(
          icon: Icon(isDramaMode ? Icons.movie_outlined : Icons.tv_outlined),
          onPressed: () {
            HapticFeedback.mediumImpact();
            homeProvider.toggleDramaMode();
            movieProvider.setDramaMode(homeProvider.isDramaMode);
          },
          tooltip: 'Switch Mode',
        ),
      ],
      bottom: bottom,
    );
  }

  void _showFilterPicker(BuildContext context, bool isDramaMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => FilterSheet(isDramaMode: isDramaMode),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (currentIndex == 1 ? 60 : 0));
}
