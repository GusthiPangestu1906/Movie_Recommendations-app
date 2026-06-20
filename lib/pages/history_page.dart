import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import 'detail_page.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                  Icon(
                    provider.searchQuery.isEmpty 
                        ? (isDramaMode ? Icons.tv : Icons.history) 
                        : Icons.search_off,
                    size: 64,
                    color: Colors.white10,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.searchQuery.isEmpty
                        ? 'No ${isDramaMode ? 'drama ' : 'movie '}history yet' 
                        : 'No matching results found',
                    style: const TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final movie = history[index];
              return _buildHistoryItem(context, movie, provider, isDramaMode);
            },
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

  Widget _buildHistoryItem(BuildContext context, Movie movie, HistoryProvider provider, bool isTv) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(movie: movie)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: movie.fullPosterPath,
                width: 90,
                height: 130,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white10),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (movie.watchDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isTv ? Colors.blueAccent : const Color(0xFF5C6AC4)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today, 
                            color: isTv ? Colors.blueAccent : const Color(0xFF5C6AC4), 
                            size: 10
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Watched: ${DateFormat('MMM dd, yyyy').format(movie.watchDate!)}',
                            style: TextStyle(
                              color: isTv ? Colors.blueAccent : const Color(0xFF5C6AC4), 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.voteAverage.toStringAsFixed(1)}',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () {
                          provider.removeFromHistory(movie.id, isTv: isTv);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from history'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    
    if (isTv) {
      await provider.searchTv(query);
      if (mounted) {
        setState(() {
          _searchResults = provider.tvSearchResults;
          _isSearching = false;
        });
      }
    } else {
      await provider.search(query);
      if (mounted) {
        setState(() {
          _searchResults = provider.searchResults;
          _isSearching = false;
        });
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
          ),
          child: child!,
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

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add to ${isTv ? 'Drama' : 'Movie'} History',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (val) => _searchData(val, isTv),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search ${isTv ? 'drama' : 'movie'} title...',
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: const Icon(Icons.search, color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
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
                              style: TextStyle(color: watched ? Colors.green.withOpacity(0.5) : Colors.white38),
                            ),
                            onTap: () => _selectDateAndAdd(item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
