import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/movie_provider.dart';
import 'search_page.dart';
import 'tv_page.dart';
import 'history_page.dart';
import 'actors_page.dart';
import '../widgets/shimmer_loading.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/movie_card.dart';

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
      const HistoryPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _updatePages();
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, _) {
          return Stack(
            children: [
              // Konten halaman utama
              _pages[_currentIndex],

              // Overlay Offline hanya untuk area Body
              if (!connectivity.isOnline)
                Container(
                  color: Colors.black, // Hitam pekat menutupi body
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
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
                            Icons.cloud_off_rounded,
                            size: 100,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Looks like you\'re\noffline!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: const Text(
                            'You\'ll see more ideas once you\'re back online.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
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

    String title = _isDramaMode ? 'Drama Universe' : 'Movie Universe';
    List<Widget> actions = [
      IconButton(
        icon: Icon(_isDramaMode ? Icons.movie_outlined : Icons.tv_outlined),
        onPressed: () {
          HapticFeedback.mediumImpact();
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
                    movieProvider.search(value);
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _isDramaMode ? 'Search Drama & TV...' : 'Search Movies...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    prefixIcon: const Icon(Icons.search, color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
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
                  color: const Color(0xFF5C6AC4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(_isDramaMode ? Icons.flag_outlined : Icons.tune, color: const Color(0xFF5C6AC4)),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showFilterPicker(context);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_currentIndex == 2) { // History
      title = _isDramaMode ? 'Drama History' : 'Movie History';
      bottom = null;
    }

    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                                    HapticFeedback.selectionClick();
                                    setModalState(() {
                                      provider.fetchTvSeries(country: country['value']!.isEmpty ? null : country['value']);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF5C6AC4) : Colors.white.withValues(alpha: 0.05),
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
                                    HapticFeedback.selectionClick();
                                    setModalState(() {
                                      provider.toggleGenre(genre['value']!);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF5C6AC4) : Colors.white.withValues(alpha: 0.05),
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
                                  backgroundColor: const Color(0xFF5C6AC4).withValues(alpha: 0.1),
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

  void _showEditProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController(text: authProvider.user?.displayName);
    String? selectedPhotoUrl = authProvider.photoUrl;
    bool isSaving = false;

    final List<String> seeds = [
      'Eden', 'Sasha', 'Willow', 'Aiden', 'Skylar', 'Nova', 'River', 'Jade',
      'Zion', 'Amara', 'Kiran', 'Lumi', 'Vesper', 'Aura', 'Orion', 'Ember'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                top: 32,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Display Name',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose Avatar',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: seeds.length,
                      itemBuilder: (context, index) {
                        final url = 'https://api.dicebear.com/7.x/lorelei/png?seed=${seeds[index]}&backgroundColor=b6e3f4,c0aede,d1d4f9';
                        final bool isSelected = selectedPhotoUrl == url;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedPhotoUrl = url;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF5C6AC4) : Colors.white12,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: const Color(0xFF5C6AC4).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ] : [],
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: url,
                                placeholder: (context, url) => Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        setModalState(() => isSaving = true);
                        try {
                          await authProvider.updateProfile(
                            name: nameController.text.trim(),
                            photoUrl: selectedPhotoUrl,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update profile: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) setModalState(() => isSaving = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6AC4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: const Color(0xFF5C6AC4).withValues(alpha: 0.5),
                      ),
                      child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
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
            decoration: const BoxDecoration(
              color: Color(0xFF1A1D2E),
              image: DecorationImage(
                image: NetworkImage('https://www.transparenttextures.com/patterns/dark-matter.png'),
                opacity: 0.1,
                repeat: ImageRepeat.repeat,
              ),
            ),
            currentAccountPicture: GestureDetector(
              onTap: () => _showEditProfile(context),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF5C6AC4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF1A1D2E),
                      radius: 36,
                      backgroundImage: authProvider.photoUrl != null
                          ? CachedNetworkImageProvider(authProvider.photoUrl!)
                          : null,
                      child: authProvider.photoUrl == null
                          ? const Icon(Icons.person, color: Colors.white30, size: 40)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5C6AC4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            accountName: Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              user?.email ?? 'guest@mymovies.app',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
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
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.movies.isEmpty) {
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: ShimmerLoading(width: 100, height: 20),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (context, index) => const MovieCardShimmer(isHorizontal: true),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: ShimmerLoading(width: 100, height: 20),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const MovieCardShimmer(),
                      childCount: 5,
                    ),
                  ),
                ),
              ],
            );
          }
          
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              if (provider.recommendations.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.recommendations.length,
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: MovieCard(
                            movie: provider.recommendations[index],
                            isHorizontal: true,
                          )
                              .animate(delay: (index * 100).ms)
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: 0.2),
                        );
                      },
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Popular',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RepaintBoundary(
                      child: MovieCard(movie: provider.movies[index])
                          .animate(delay: (index * 50).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1),
                    ),
                    childCount: provider.movies.length,
                  ),
                ),
              ),

              if (provider.isFetchingMore)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const MovieCardShimmer(),
                      childCount: 2,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }

  // _buildHorizontalCard and _buildStandardCard removed - now using MovieCard widget
}
