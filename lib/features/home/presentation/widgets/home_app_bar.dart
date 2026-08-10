import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/history_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../../../tv/presentation/providers/tv_provider.dart';
import '../providers/home_provider.dart';
import 'filter_sheet.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final bool isWeb;

  const HomeAppBar({super.key, required this.currentIndex, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    final tvProvider = Provider.of<TvProvider>(context, listen: false);
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );
    final isDramaMode = homeProvider.isDramaMode;

    if (isWeb) {
      return _buildWebAppBar(context, homeProvider, isDramaMode);
    }

    String title = isDramaMode ? 'NYXDEX DRAMA' : 'NYXDEX MOVIES';
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
                  onChanged: (value) => searchProvider.search(
                    value,
                    isDramaMode: isDramaMode,
                    selectedCountry: tvProvider.selectedCountry,
                    history: historyProvider.allHistory,
                  ),
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
      title = isDramaMode ? 'History' : 'History';
    }

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          fontSize: 18,
        ),
      ),
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
            tvProvider.setDramaMode(homeProvider.isDramaMode);
          },
          tooltip: 'Switch Mode',
        ),
      ],
      bottom: bottom,
    );
  }

  Widget _buildWebAppBar(
    BuildContext context,
    HomeProvider homeProvider,
    bool isDramaMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(
        children: [
          const Text(
            'NYXDEX',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 60),
          _navItem("MOVIES", !isDramaMode, () {
            if (isDramaMode) homeProvider.toggleDramaMode();
          }),
          const SizedBox(width: 30),
          _navItem("TV SERIES", isDramaMode, () {
            if (!isDramaMode) homeProvider.toggleDramaMode();
          }),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  isDramaMode
                      ? Icons.tv_rounded
                      : Icons.movie_creation_outlined,
                  size: 16,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 10),
                Text(
                  isDramaMode ? "TV MODE" : "MOVIE MODE",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white10,
            child: Icon(Icons.person_outline, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white38,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 6),
              height: 2,
              width: 15,
              color: Colors.blueAccent,
            ),
        ],
      ),
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
  Size get preferredSize => Size.fromHeight(
    isWeb ? 80 : (kToolbarHeight + (currentIndex == 1 ? 60 : 0)),
  );
}
