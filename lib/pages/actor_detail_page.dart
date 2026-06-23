import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void _launchSocial(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
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
            imageUrl: _actorDetails!.fullProfilePathHD,
            width: double.infinity,
            height: 550,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.white10),
            errorWidget: (context, url, error) => Container(
              height: 550,
              color: Colors.white10,
              child: const Icon(Icons.person, color: Colors.white30, size: 80),
            ),
          ),
        ),
        // Top-down dark gradient for back/fav buttons visibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Premium Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF0B0E1E).withOpacity(0.2),
                  const Color(0xFF0B0E1E).withOpacity(0.8),
                  const Color(0xFF0B0E1E),
                ],
                stops: const [0.4, 0.6, 0.85, 1.0],
              ),
            ),
          ),
        ),
        // Glassmorphism Back Button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: _buildGlassButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        // Glassmorphism Favorite Button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: Consumer<MovieProvider>(
            builder: (context, provider, child) {
              final isFav = provider.isFavoriteActor(widget.actorId);
              return _buildGlassButton(
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                iconColor: isFav ? Colors.redAccent : Colors.white,
                onTap: () {
                  if (_actorDetails != null) {
                    provider.toggleFavoriteActor(_actorDetails!);
                  }
                },
              );
            },
          ),
        ),
        // Actor Name floating on header
        Positioned(
          bottom: 20,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.actorName,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  if (_actorDetails?.instagramId != null && _actorDetails!.instagramId!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: GestureDetector(
                        onTap: () => _launchSocial('https://instagram.com/${_actorDetails!.instagramId}'),
                        child: _buildBootstrapInstagramIcon(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap, Color iconColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBootstrapInstagramIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: SvgPicture.asset(
        'assets/instagram.svg',
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        width: 24,
        height: 24,
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildQuickStatsBar(),
          const SizedBox(height: 32),
          _buildBiography(),
          const SizedBox(height: 32),
          _buildDynamicVerifiedSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuickStatsBar() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildStatTile(Icons.cake_rounded, 'BORN', _actorDetails!.birthday ?? 'N/A', const Color(0xFFFFAB40))),
          const SizedBox(width: 10),
          Expanded(child: _buildStatTile(Icons.location_on_rounded, 'FROM', _actorDetails!.placeOfBirth?.split(',').last.trim() ?? 'N/A', const Color(0xFF448AFF))),
          const SizedBox(width: 10),
          Expanded(child: _buildStatTile(Icons.trending_up_rounded, 'RANK', _actorDetails!.popularity?.toStringAsFixed(1) ?? 'N/A', const Color(0xFF64FFDA))),
        ],
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Reduced size slightly to accommodate more text
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        Row(
          children: [
            const Text(
              'Biography',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Icon(Icons.notes, color: Colors.white.withOpacity(0.2), size: 20),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedCrossFade(
          firstChild: Text(
            bio,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 15),
          ),
          secondChild: Text(
            bio,
            style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 15),
          ),
          crossFadeState: _isBiographyExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (canExpand)
          GestureDetector(
            onTap: () => setState(() => _isBiographyExpanded = !_isBiographyExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    _isBiographyExpanded ? 'Show Less' : 'Read Full Bio',
                    style: const TextStyle(color: Color(0xFF5C6AC4), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isBiographyExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF5C6AC4),
                    size: 18,
                  ),
                ],
              ),
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
            'Filmography',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final movieCount = _verifiedMovies?.length ?? 0;
    final tvCount = _verifiedTv?.length ?? 0;

    return Column(
      children: [
        if (movieCount > 0) ...[
          _buildCategorizedFilmography('Top Movies', _verifiedMovies!),
          const SizedBox(height: 32),
        ],
        if (tvCount > 0)
          _buildCategorizedFilmography('Top TV Series', _verifiedTv!),
      ],
    );
  }

  Widget _buildCategorizedFilmography(String title, List<Movie> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '${list.length} items',
              style: const TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildFilmographyCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilmographyCard(Movie item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(movie: item)),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: item.fullPosterPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(color: Colors.white10),
                    errorWidget: (context, url, error) => const Icon(Icons.movie, color: Colors.white10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  item.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  item.releaseDate.isNotEmpty ? item.releaseDate.split('-')[0] : 'N/A',
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ],
            ),
            if (item.character != null && item.character!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  item.character!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF5C6AC4), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
