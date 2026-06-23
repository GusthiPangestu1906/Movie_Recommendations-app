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
  final ScrollController _scrollController = ScrollController();

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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final provider = Provider.of<MovieProvider>(context, listen: false);
        if (_tvSearchController.text.isEmpty) {
          provider.fetchMoreTvSeries();
        } else {
          provider.fetchMoreSearchResults();
        }
      }
    });
  }

  @override
  void dispose() {
    _tvSearchController.dispose();
    _scrollController.dispose();
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
            child: provider.isLoading && (provider.tvSeries.isEmpty && provider.tvSearchResults.isEmpty)
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C6AC4)))
                : _buildTvList(provider),
          ),
        ],
      ),
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
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: list.length + (provider.isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return MovieCard(movie: list[index]);
      },
    );
  }
}
