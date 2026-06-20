import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import 'detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ActorDetailPage extends StatefulWidget {
  final int actorId;
  final String actorName;

  const ActorDetailPage({super.key, required this.actorId, required this.actorName});

  @override
  State<ActorDetailPage> createState() => _ActorDetailPageState();
}

class _ActorDetailPageState extends State<ActorDetailPage> {
  Cast? _actorDetails;
  List<Movie>? _verifiedMovies;
  List<Movie>? _verifiedTv;
  bool _isLoadingBasic = true;
  bool _isLoadingFilmography = true;
  bool _isBiographyExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<MovieProvider>(context, listen: false);
    
    // Phase 1: Load Basic Info (Biography, Birthday, etc.)
    final details = await provider.getFullActorDetails(widget.actorId);
    if (mounted) {
      setState(() {
        _actorDetails = details;
        _isLoadingBasic = false;
      });
    }

    // Phase 2: Load Verified Filmography in background
    if (details != null) {
      final work = await provider.fetchVerifiedWork(widget.actorId);
      if (mounted) {
        setState(() {
          _verifiedMovies = work['movies'];
          _verifiedTv = work['tv'];
          _isLoadingFilmography = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      body: _isLoadingBasic 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5C6AC4)))
          : _actorDetails == null
              ? const Center(child: Text('Failed to load actor details', style: TextStyle(color: Colors.white38)))
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(),
                            const SizedBox(height: 24),
                            _buildBiography(),
                            const SizedBox(height: 32),
                            _buildDynamicVerifiedSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: const Color(0xFF0B0E1E),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.actorName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _actorDetails!.fullProfilePath,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.white10),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF0B0E1E)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoColumn('Born', _actorDetails!.birthday ?? 'N/A'),
        _buildInfoColumn('From', _actorDetails!.placeOfBirth?.split(',').last.trim() ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildBiography() {
    final bio = _actorDetails!.biography?.isNotEmpty == true 
        ? _actorDetails!.biography! 
        : 'No biography available for this actor.';
    
    final bool canExpand = bio.length > 300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biography',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          canExpand && !_isBiographyExpanded ? '${bio.substring(0, 300)}...' : bio,
          style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 14),
        ),
        if (canExpand)
          TextButton(
            onPressed: () => setState(() => _isBiographyExpanded = !_isBiographyExpanded),
            child: Text(
              _isBiographyExpanded ? 'Read Less' : 'Read More',
              style: const TextStyle(color: Color(0xFF5C6AC4), fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildDynamicVerifiedSection() {
    if (_isLoadingFilmography) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verifying Filmography...',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 130,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final movieCount = _verifiedMovies?.length ?? 0;
    final tvCount = _verifiedTv?.length ?? 0;

    if (movieCount >= tvCount && movieCount > 0) {
      return _buildCategorizedFilmography('Verified Movies', _verifiedMovies);
    } else if (tvCount > 0) {
      return _buildCategorizedFilmography('Verified Dramas', _verifiedTv);
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategorizedFilmography(String title, List<Movie>? list) {
    if (list == null || list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailPage(movie: item)),
                  );
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: item.fullPosterPath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(color: Colors.white10),
                            errorWidget: (context, url, error) => const Icon(Icons.movie, color: Colors.white10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isTv ? 'Involved in Drama' : 'Involved in Film',
                        style: const TextStyle(color: Color(0xFF5C6AC4), fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
