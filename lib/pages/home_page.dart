import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import 'detail_page.dart';
import 'search_page.dart';
import 'tv_page.dart';
import 'favorite_page.dart';
import 'history_page.dart';
import 'actors_page.dart';
import '../widgets/movie_card.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isDramaMode = false;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _updatePages();
  }

  void _updatePages() {
    _pages = [
      _isDramaMode ? const TvPage() : const MovieListScreen(),
      const SearchPage(),
      const FavoritePage(),
      const HistoryPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _updatePages();
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF0B0E1E),
          selectedItemColor: const Color(0xFF5C6AC4),
          unselectedItemColor: Colors.white30,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(_isDramaMode ? Icons.tv : Icons.movie_filter),
              ),
              label: _isDramaMode ? 'Drama' : 'Movies',
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
                child: Icon(Icons.favorite_border),
              ),
              label: 'Favorites',
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);
    
    String title = _isDramaMode ? 'Drama Universe' : 'Movie Universe';
    List<Widget> actions = [
      IconButton(
        icon: Icon(_isDramaMode ? Icons.movie_outlined : Icons.tv_outlined),
        onPressed: () {
          setState(() {
            _isDramaMode = !_isDramaMode;
          });
          movieProvider.setDramaMode(_isDramaMode);
        },
        tooltip: 'Switch Mode',
      ),
    ];
    PreferredSizeWidget? bottom;

    if (_currentIndex == 0) { // Home
      // Icons removed as requested
    } else if (_currentIndex == 1) { // Search
      title = _isDramaMode ? 'Search Dramas' : 'Search Movies';
      bottom = PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    if (_isDramaMode) {
                      movieProvider.searchTv(value);
                    } else {
                      movieProvider.search(value);
                    }
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _isDramaMode ? 'Search Drama & TV...' : 'Search Movies...',
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
                  icon: Icon(_isDramaMode ? Icons.flag_outlined : Icons.tune, color: const Color(0xFF5C6AC4)),
                  onPressed: () => _showFilterPicker(context),
                ),
              ),
            ],
          ),
        ),
      );
    }
else if (_currentIndex == 2) { // Favorites
      title = _isDramaMode ? 'Favorite Stars' : 'Favorite Movies';
    } else if (_currentIndex == 3) { // History
      title = _isDramaMode ? 'Drama History' : 'Movie History';
      bottom = PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            onChanged: (value) => historyProvider.setSearchQuery(value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search in history...',
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
      );
    }

    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_open),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  final List<Map<String, String>> _genres = [
    {'label': 'Action', 'value': '28'},
    {'label': 'Adventure', 'value': '12'},
    {'label': 'Animation', 'value': '16'},
    {'label': 'Comedy', 'value': '35'},
    {'label': 'Crime', 'value': '80'},
    {'label': 'Drama', 'value': '18'},
    {'label': 'Fantasy', 'value': '14'},
    {'label': 'Horror', 'value': '27'},
    {'label': 'Mystery', 'value': '9648'},
    {'label': 'Romance', 'value': '10749'},
    {'label': 'Sci-Fi', 'value': '878'},
    {'label': 'Thriller', 'value': '53'},
  ];

  final List<Map<String, String>> _countries = [
    {'label': 'All Countries', 'value': ''},
    {'label': 'Korea (K-Drama)', 'value': 'KR'},
    {'label': 'Japan (J-Drama)', 'value': 'JP'},
    {'label': 'China (C-Drama)', 'value': 'CN'},
    {'label': 'USA', 'value': 'US'},
    {'label': 'Thailand', 'value': 'TH'},
  ];

  void _showFilterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final provider = Provider.of<MovieProvider>(context);
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        children: [
                          Text(
                            _isDramaMode ? 'Drama Selection' : 'Filter Movies',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isDramaMode ? 'Select Origin Country' : 'Select Movie Genres',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          if (_isDramaMode)
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _countries.map((country) {
                                final isSelected = (provider.selectedCountry ?? '') == country['value'];
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      provider.fetchTvSeries(country: country['value']!.isEmpty ? null : country['value']);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF5C6AC4) : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
                                    ),
                                    child: Text(
                                      country['label']!,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _genres.map((genre) {
                                final isSelected = provider.selectedGenreIds.contains(genre['value']);
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      provider.toggleGenre(genre['value']!);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF5C6AC4) : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
                                    ),
                                    child: Text(
                                      genre['label']!,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    if (!_isDramaMode)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  provider.applyGenreFilter();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5C6AC4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Apply Combined Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5C6AC4).withOpacity(0.1),
                                  foregroundColor: const Color(0xFF5C6AC4),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      backgroundColor: const Color(0xFF0B0E1E),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A1D2E)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Color(0xFF5C6AC4),
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            accountName: Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              user?.email ?? 'guest@mymovies.app',
              style: const TextStyle(color: Colors.white38),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.movie_filter,
            label: 'Movie Universe',
            isSelected: !_isDramaMode,
            onTap: () {
              setState(() {
                _isDramaMode = false;
                _currentIndex = 0;
              });
              Provider.of<MovieProvider>(context, listen: false).setDramaMode(false);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.tv,
            label: 'Drama Universe',
            isSelected: _isDramaMode,
            onTap: () {
              setState(() {
                _isDramaMode = true;
                _currentIndex = 0;
              });
              Provider.of<MovieProvider>(context, listen: false).setDramaMode(true);
              Navigator.pop(context);
            },
          ),
          const Divider(color: Colors.white10, height: 40),
          _buildDrawerItem(
            icon: Icons.people_outline,
            label: 'Favorite Stars',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteActorsPage()),
              );
            },
          ),
          const Spacer(),
          _buildDrawerItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pop(context); // Close drawer
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF5C6AC4) : Colors.white30),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      provider.fetchNowPlaying();
      provider.fetchRecommendations(history: historyProvider.history);
    });
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        Provider.of<MovieProvider>(context, listen: false).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Sort by Category',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildCategoryItem(context, 'Now Playing', 'now_playing'),
            _buildCategoryItem(context, 'Popular', 'popular'),
            _buildCategoryItem(context, 'Top Rated', 'top_rated'),
            _buildCategoryItem(context, 'Upcoming', 'upcoming'),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        Provider.of<MovieProvider>(context, listen: false).fetchByCategory(value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.movies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), // Padding for missing AppBar
                if (provider.recommendations.isNotEmpty) ...[
                  _buildSectionTitle('For You', showSort: false, onCategory: () {}),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.recommendations.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          movie: provider.recommendations[index],
                          isHorizontal: true,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildSectionTitle('Popular', showSort: true, onCategory: () => _showCategoryPicker(context)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.movies.length,
                  itemBuilder: (context, index) {
                    return MovieCard(movie: provider.movies[index]);
                  },
                ),
                if (provider.isFetchingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool showSort, required VoidCallback onCategory}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // _buildHorizontalCard and _buildStandardCard removed - now using MovieCard widget
}
