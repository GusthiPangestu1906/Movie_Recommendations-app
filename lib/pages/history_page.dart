import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../providers/history_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/connectivity_provider.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddHistoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1D2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const AddHistoryBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final isDramaMode = movieProvider.isDramaMode;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          // Dynamically select history based on global app mode
          final history = isDramaMode ? provider.filteredTvHistory : provider.filteredHistory;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.searchQuery.isEmpty
                        ? 'Your ${isDramaMode ? 'drama ' : 'movie '}journal is empty'
                        : 'No matches in your history',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.searchQuery.isEmpty
                        ? 'Start adding what you\'ve watched!'
                        : 'Try a different search term',
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RepaintBoundary(
                      child: MovieCard(movie: history[index])
                          .animate(delay: (index * 50).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1),
                    ),
                    childCount: history.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHistoryDialog(context),
        backgroundColor: const Color(0xFF5C6AC4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // _buildHistoryItem removed - now using MovieCard widget
}

class AddHistoryBottomSheet extends StatefulWidget {
  const AddHistoryBottomSheet({super.key});

  @override
  State<AddHistoryBottomSheet> createState() => _AddHistoryBottomSheetState();
}

class _AddHistoryBottomSheetState extends State<AddHistoryBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, bool isTv) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchData(query, isTv);
    });
  }

  void _searchData(String query, bool isTv) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final provider = Provider.of<MovieProvider>(context, listen: false);
    
    try {
      final results = await provider.searchForHistory(query, isTv: isTv);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectDateAndAdd(Movie movie) async {
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    
    if (historyProvider.isWatched(movie.id)) {
      final watchDate = historyProvider.getWatchDate(movie.id);
      final dateStr = watchDate != null ? DateFormat('MMM dd, yyyy').format(watchDate) : 'Unknown date';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${movie.title}" is already in history (Watched on $dateStr)'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF5C6AC4),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1D2E),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      Provider.of<HistoryProvider>(context, listen: false).addToHistory(movie, picked);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to History'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTv = Provider.of<MovieProvider>(context).isDramaMode;

    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add to ${isTv ? 'Drama' : 'Movie'} History',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    enabled: connectivity.isOnline, // Disable input if offline
                    onChanged: (val) => _onSearchChanged(val, isTv),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search ${isTv ? 'drama' : 'movie'} title...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      prefixIcon: const Icon(Icons.search, color: Colors.white24),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white24),
                              onPressed: () {
                                _searchController.clear();
                                _searchData('', isTv);
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isSearching
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C6AC4)))
                        : _searchResults.isEmpty && _searchController.text.isNotEmpty
                            ? const Center(child: Text('No results found', style: TextStyle(color: Colors.white38)))
                            : ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final item = _searchResults[index];
                                  final bool watched = Provider.of<HistoryProvider>(context, listen: false).isWatched(item.id);

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                    leading: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: item.fullPosterPath,
                                            width: 50,
                                            height: 75,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) => const Icon(Icons.movie),
                                          ),
                                        ),
                                        if (watched)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                                            ),
                                          ),
                                      ],
                                    ),
                                    title: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: watched ? Colors.white38 : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: watched ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      watched ? 'Already in History' : (item.releaseDate.isNotEmpty ? item.releaseDate.split('-')[0] : 'N/A'),
                                      style: TextStyle(color: watched ? Colors.green.withValues(alpha: 0.5) : Colors.white38),
                                    ),
                                    onTap: () => _selectDateAndAdd(item),
                                  );
                                },
                              ),
                  ),
                ],
              ),

              // Overlay Offline untuk modal search
              if (!connectivity.isOnline)
                Container(
                  color: const Color(0xFF1A1D2E), // Match bottom sheet color
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          color: Colors.white24,
                          size: 70,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Offline Mode',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Connect to search and add history.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
