import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import 'detail_page.dart';
import '../widgets/movie_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TvPage extends StatefulWidget {
  const TvPage({super.key});

  @override
  State<TvPage> createState() => _TvPageState();
}

class _TvPageState extends State<TvPage> {
  final TextEditingController _tvSearchController = TextEditingController();
  bool _isSearching = false;

  final List<Map<String, String>> _countries = [
    {'label': 'All Countries', 'value': ''},
    {'label': 'Korea (K-Drama)', 'value': 'KR'},
    {'label': 'Japan (J-Drama)', 'value': 'JP'},
    {'label': 'China (C-Drama)', 'value': 'CN'},
    {'label': 'USA', 'value': 'US'},
    {'label': 'Thailand', 'value': 'TH'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MovieProvider>(context, listen: false).fetchTvSeries();
    });
  }

  @override
  void dispose() {
    _tvSearchController.dispose();
    super.dispose();
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final provider = Provider.of<MovieProvider>(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Origin Country',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._countries.map((country) {
                final isSelected = (provider.selectedCountry ?? '') == country['value'];
                return ListTile(
                  leading: Icon(
                    Icons.flag_outlined,
                    color: isSelected ? const Color(0xFF5C6AC4) : Colors.white30,
                  ),
                  title: Text(
                    country['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF5C6AC4)) : null,
                  onTap: () {
                    provider.fetchTvSeries(country: country['value']!.isEmpty ? null : country['value']);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MovieProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C6AC4)))
                : _buildTvList(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteActorsSection(MovieProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Favorite Actors & Actresses',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.favoriteActors.length,
            itemBuilder: (context, index) {
              final actor = provider.favoriteActors[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(actor.fullProfilePath),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Text(
                        actor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.white10),
      ],
    );
  }

  Widget _buildTvList(MovieProvider provider) {
    final list = _tvSearchController.text.isNotEmpty 
        ? provider.tvSearchResults 
        : provider.tvSeries;

    if (list.isEmpty) {
      return const Center(
        child: Text('No dramas found', style: TextStyle(color: Colors.white38)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return MovieCard(movie: list[index]);
      },
    );
  }

  // _buildTvCard removed - now using MovieCard widget
}
