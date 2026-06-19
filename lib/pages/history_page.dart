import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import '../services/seeder_service.dart';
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

  void _importBulkData(BuildContext context) async {
    final seeder = SeederService();
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D2E),
        title: const Text('Importing Data', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF5C6AC4)),
            const SizedBox(height: 20),
            const Text('Please wait while we sync your movies...', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Checking TMDb database...', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );

    const String rawData = """
Term Life
Transporter 3
Day of the Dead : Bloodline
Mortal Kombat
Freelance
No Way Up
Kong: Skull Island
Run Hide Fight
Black Adam 
The Dark Knight
Batman v Superman: Dawn of Justice
Moonfall
San Andreas 
Captain Phillips
Fall
Blacklight
The Equalizer
Run
Bloodshot
Hunter Killer 
White House Down 
Sweet 20
Badarawuhi di Desa Penari
KKN di Desa Penari
King Kong
Jurassic World Dominion
Jurassic World: Fallen Kingdom
Jurassic Park 
Wrath of the Titans
Moonfall
Man on a Ledge
Sabtu, 26 Juli 25 : Red
Senin, 12 Mei 25 : Suicide Squad
Gunpowder Milkshake
Hidden Strike
BLIND SWORD
The Legend of Tarzan
The Dark Knight 
Angels and Demon 
Inferno 
The Hitman's Bodyguard 
In Time 
Hypnotic 
The Scorpion king 
Fast and furious 
Enter The Fat Dragon 
The Gunman
Shotgun Wedding 
Minggu, 9 Juni 2024 : Homefront 
Skyscapper 
Viral
Snow white and the Huntsman 
Baby Driver
Clash of the Titans 
The Protege
Ice Road
Overdrive
Clean with passion for now
Greenland
The perfect storm
John Wick: Chapter 4
Blue Beetle
Elemental: Forces of Nature
The Creator 
Edge of Tomorrow 
Blacklight
Geostorm
Bastile day 
Twinkling Watermelon
Green Lantern
Homefront
Jumat, 1 Agustus 2023 : John Wick
Rabu, 16 Agustus 2023 : Midway
Minggu, 1 Juni 2023 : Replicas
Jumat, 30 Juni 2023 : Premium Rush
Rabu, 28 Juni 2023 : 1911
Minggu, 25 Juni 2023 : Charlie's Angels
Kamis, 22 Juni 2023 : Contagion
Rabu, 21 Juni 2023 : Angel Has Fallen
Selasa, 20 Juni 2023 : London Has Fallen
Sabtu, 17 Juni 2023 : 300: Rise of an Empire
Minggu, 11 Juni 2023 : 300
Rabu, 31 Mei 2023 : USS Indianapolis: Men of Courage
Sabtu, 27 Mei 2023 : Suicide Squad
Sabtu, 13 Mei 2023 : Greenland 
Jumat, 28 April 2023 : 
1. Police Story : Lockdown (Police Story 2013)
2. The Divergent Series: Insurgent
Kamis, 27 April 2023 : 
1. Little Big Soldier
2. Wish Upon
Rabu, 26 April 2023 : Skiptrace
Selasa, 25 April 2023 : Bleeding Steel
Minggu, 23 April 2023 : Clash of the Titans 
Sabtu, 22 April 2023 : Pacific Rim 
Jumat, 21 April 2023 : 
1. Riddick
2. The Meg 
3. Rampage 
Kamis, 20 April 2023 : Legendary: Tomb of the Dragon
Selasa, 19 April 2023 : Primal
Senin, 17 April 2023 : Sabotage
Jumat, 7 April 2023 : Hacksaw Ridge
Selasa, 21 Maret 2023 : Resident Evil: Retribution
Jumat, 17 Maret 2023 : Resident Evil: Afterlife
Jumat, 10 Maret 2023 : The Divergent Series: Allegiant 
Sabtu, 25 Feb 2023 :
• Badges of Fury 
• Hotel Mumbai 
Sabtu, 28 Jan 2023 : The Spy Who Dumped Me
Rabu, 28 Des 2022 : 
• Olympus Has Fallen
• Despicable Me
Selasa, 27 Des 2022 : Daredevil
Minggu, 25 Des 2022 : 
• The Karate Kid
• Zombieland: Double Tap
Sabtu, 24 Des 2022 : 
• Zombieland
• Doraemon the Movie: Nobita's Treasure Island
Jumat, 23 Des 2022 : Gone Girl
Kamis, 22 Des 2022 : 
• Asterix: The Secret of the Magic Potion
• The Courier
Rabu, 21 Des 2022 : Shark Tale
Sel, 20 Des 2022 : Mr. Peabody & Sherman
Sen, 19 Des 2022 : Spider-Man: Far from Home
Sab, 10 Des 2022 :
• The Forbidden Kingdom
• Honest Thief
Sab, 3 Desember 2022 : Valerian and The City of A Thousand Planets
Sab, 26 November 2022 : Imperfect: Karier, Cinta & Timbangan
Jum, 25 November 2022 : Non-Stop
Jum, 11 November 2022 : 
• Blade Runner 2049
• Jumper 
Jum, 4 November 2022 : Gods of Egypt
Jum, 21 Oktober 2022 : AD ASTRA
Jum, 14 Oktober 2022 : Assassin's Creed 
Jum, 7 Oktober 2022 : Deepwater Horizon 
Sabtu, 24 September 2022 : Chaos Walking
Jumat 16 September 2022 : 47 Meters Down : Uncaged
Sabtu 3 September 2022 : Line of Duty
Sabtu 20 Agustus 2022 : Winchester 
Sabtu 16 Juli 2022 : Golden Job 
Kamis 14 Juli 2022 : Bastille Day 
Senin 11 Juli 2022 : Rambo : The Last Blood 
Minggu 10 Juli 2022 : The Last Witch Hunter
Sabtu 9 Juli 2022 : Master Z : The IP Man Legency 
Jumat 7 Juli 2022 : American Sniper
Rabu 6 Juli 2022 : Sicario 
Selasa 5 Juli 2022 : Brick Mansions
Senin 4 Juli 2022 : Taken
Minggu 3 Juli 2022 : Mechanic : Resurrection
Sabtu 2 Juli 2022 : Big Brother 
Jumat 1 Juli 2022 : The Hurricane Heist
Kamis 30 Juni 2022 : Crazy Rich Asians
Rabu 29 Juni 2022 : Ghost Rider: Spirit of Vengeance
Selasa 28 Juni 2022 : Final Score
Senin 27 Juni 2022 : Wonder Woman
Jum, 22 Desember 2023 : Wonder Woman
""";

    await seeder.seedData(provider, rawData, (current, total) => {});

    if (context.mounted) {
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bulk import completed! All data synced.'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      appBar: AppBar(
        title: const Text('Watch History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined, color: Colors.blueAccent),
            tooltip: 'Import Bulk Data',
            onPressed: () => _importBulkData(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                Provider.of<HistoryProvider>(context, listen: false).setSearchQuery(value);
              },
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
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          final history = provider.filteredHistory;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isEmpty ? Icons.history : Icons.search_off,
                    size: 64,
                    color: Colors.white10,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty 
                        ? 'No history yet' 
                        : 'No matching history found',
                    style: const TextStyle(color: Colors.white38, fontSize: 18),
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
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: movie.fullPosterPath,
                          width: 100,
                          height: 140,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (movie.watchDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5C6AC4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_today, color: Color(0xFF5C6AC4), size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Watched: ${DateFormat('MMM dd, yyyy').format(movie.watchDate!)}',
                                      style: const TextStyle(color: Color(0xFF5C6AC4), fontSize: 11, fontWeight: FontWeight.bold),
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
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${movie.voteAverage.toStringAsFixed(1)}/10 IMDb',
                                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    provider.removeFromHistory(movie.id);
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

  void _searchMovies(String query) async {
    // This already uses onChanged, but let's make it feel more like "guessing" 
    // by ensuring it triggers the MovieProvider search which now has debounce
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    // Reuse the search logic from MovieProvider for consistency
    final provider = Provider.of<MovieProvider>(context, listen: false);
    await provider.search(query);
    
    // Add a small delay to let the debounce in provider finish if we want local state update
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (mounted) {
      setState(() {
        _searchResults = provider.searchResults;
        _isSearching = false;
      });
    }
  }

  void _selectDateAndAdd(Movie movie) async {
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    
    if (historyProvider.isWatched(movie.id)) {
      final watchDate = historyProvider.getWatchDate(movie.id);
      final dateStr = watchDate != null ? DateFormat('MMM dd, yyyy').format(watchDate) : 'Unknown date';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${movie.title}" is already in your history (Watched on $dateStr)'),
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
          content: Text('Added "${movie.title}" to History'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Add to Watch History',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: _searchMovies,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search movie title...',
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
                    ? const Center(child: Text('No movies found', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final movie = _searchResults[index];
                          final bool watched = Provider.of<HistoryProvider>(context, listen: false).isWatched(movie.id);
                          
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: movie.fullPosterPath,
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
                              movie.title,
                              style: TextStyle(
                                color: watched ? Colors.white38 : Colors.white, 
                                fontWeight: FontWeight.bold,
                                decoration: watched ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text(
                              watched ? 'Already in History' : (movie.releaseDate.isNotEmpty ? movie.releaseDate.split('-')[0] : 'N/A'),
                              style: TextStyle(color: watched ? Colors.green.withOpacity(0.5) : Colors.white38),
                            ),
                            trailing: Icon(
                              watched ? Icons.done_all : Icons.calendar_today, 
                              color: watched ? Colors.green : const Color(0xFF5C6AC4), 
                              size: 20
                            ),
                            onTap: () => _selectDateAndAdd(movie),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
