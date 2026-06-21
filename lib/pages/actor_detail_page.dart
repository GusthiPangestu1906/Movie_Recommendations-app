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
    
    // Phase 1: Load Basic Info
    final details = await provider.getFullActorDetails(widget.actorId);
    if (mounted) {
      setState(() {
        _actorDetails = details;
        _isLoadingBasic = false;
      });
    }

    // Phase 2: Load Verified Filmography
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildContent(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Hero(
          tag: 'actor-backdrop-${widget.actorId}',
          child: CachedNetworkImage(
            imageUrl: _actorDetails!.fullProfilePath,
            width: double.infinity,
            height: 450,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.white10),
            errorWidget: (context, url, error) => Container(
              height: 450,
              color: Colors.white10,
              child: const Icon(Icons.person, color: Colors.white30, size: 80),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xFF0B0E1E)],
                stops: [0.6, 1.0],
              ),
            ),
          ),
        ),
        // FIXED BACK BUTTON - REORDERED TO BE ON TOP
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0E1E),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.actorName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Consumer<MovieProvider>(
                builder: (context, provider, child) {
                  final isFav = provider.isFavoriteActor(widget.actorId);
                  return IconButton(
                    onPressed: () {
                      if (_actorDetails != null) {
                        provider.toggleFavoriteActor(_actorDetails!);
                      }
                    },
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.redAccent : Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(),
          const SizedBox(height: 32),
          _buildBiography(),
          const SizedBox(height: 32),
          _buildDynamicVerifiedSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.cake_outlined, 'Born', _actorDetails!.birthday ?? 'N/A'),
          Container(width: 1, height: 30, color: Colors.white10),
          _buildInfoItem(Icons.location_on_outlined, 'From', _actorDetails!.placeOfBirth?.split(',').last.trim() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF5C6AC4), size: 20),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
        const SizedBox(height: 16),
        Text(
          canExpand && !_isBiographyExpanded ? '${bio.substring(0, 300)}...' : bio,
          style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 14),
        ),
        if (canExpand)
          TextButton(
            onPressed: () => setState(() => _isBiographyExpanded = !_isBiographyExpanded),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
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
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
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
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: item.fullPosterPath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(color: Colors.white10),
                            errorWidget: (context, url, error) => const Icon(Icons.movie, color: Colors.white10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isTv ? 'Involved in Drama' : 'Involved in Movie',
                        style: const TextStyle(color: Color(0xFF5C6AC4), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      if (item.character != null && item.character!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'as ${item.character}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white38, fontSize: 9, fontStyle: FontStyle.italic),
                          ),
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
