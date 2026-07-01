import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../providers/history_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'actor_detail_page.dart';

import '../widgets/movie_card.dart';

class DetailPage extends StatefulWidget {
  final Movie movie;
  const DetailPage({super.key, required this.movie});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<MovieProvider>(context, listen: false).loadMovieExtras(widget.movie));
  }

  void _playTrailer(String? key) async {
    if (key != null) {
      final url = Uri.parse('https://www.youtube.com/watch?v=$key');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trailer not available')),
      );
    }
  }

  String _getFormattedRating(String? cert) {
    if (cert == null || cert.isEmpty) return 'General';
    if (cert.toUpperCase() == 'R') return 'For 18+';
    return cert;
  }

  void _watchOnPlatform(String title, bool isTv) async {
    final encodedTitle = Uri.encodeComponent(title);
    // For Movies we use Netflix, for Dramas we use WeTV
    final url = isTv
        ? Uri.parse('https://wetv.vip/search?q=$encodedTitle')
        : Uri.parse('https://www.netflix.com/search?q=$encodedTitle');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${isTv ? 'WeTV' : 'Netflix'}')),
      );
    }
  }

  void _selectWatchDate(BuildContext context) async {
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
      if (!context.mounted) return;
      Provider.of<HistoryProvider>(context, listen: false).addToHistory(widget.movie, picked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to History: ${DateFormat('yyyy-MM-dd').format(picked)}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1E),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 50),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.movie.fullBackdropPath,
                          width: double.infinity,
                          height: 420,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorWidget: (context, url, error) => Container(
                            height: 420,
                            color: Colors.white10,
                            child: const Icon(Icons.broken_image, color: Colors.white30),
                          ),
                        ),
                    if (widget.movie.trailerKey != null)
                      Positioned.fill(
                        child: Center(
                          child: GestureDetector(
                            onTap: () => _playTrailer(widget.movie.trailerKey),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Play Trailer',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // BACK & WATCHED BUTTONS
                    Positioned(
                      top: 20,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ),
                          Consumer<HistoryProvider>(
                            builder: (context, history, _) {
                              final isWatched = history.isWatched(widget.movie.id);
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isWatched) {
                                        // If already watched, show option to unmark
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: const Color(0xFF1A1D2E),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (context) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(height: 8),
                                              Container(
                                                width: 40,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: Colors.white24,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Watched History',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ListTile(
                                                leading: const Icon(Icons.edit_calendar, color: Colors.blueAccent),
                                                title: const Text('Change Watch Date', style: TextStyle(color: Colors.white)),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _selectWatchDate(context);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                title: const Text('Unmark Watched', style: TextStyle(color: Colors.white)),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  history.removeFromHistory(widget.movie.id, isTv: widget.movie.isTv);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Removed from history'),
                                                      backgroundColor: Colors.redAccent,
                                                      behavior: SnackBarBehavior.floating,
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          ),
                                        );
                                      } else {
                                        _selectWatchDate(context);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isWatched ? Colors.green.withValues(alpha: 0.8) : Colors.black45,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isWatched ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.white10,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isWatched ? Icons.check_circle : Icons.add_task_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isWatched ? 'WATCHED' : 'MARK WATCHED',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.movie.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(provider.isFavorite(widget.movie.id) ? Icons.favorite : Icons.favorite_border),
                        color: provider.isFavorite(widget.movie.id) ? Colors.redAccent : Colors.white,
                        onPressed: () {
                          provider.toggleFavorite(widget.movie);
                        },
                      ),
                    ],
                  ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.movie.voteAverage.round()}/10 IMDb',
                          style: const TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChip('ACTION'),
                        _buildChip('ADVENTURE'),
                        _buildChip('FANTASY'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem('Length', '2h 28min'),
                        _buildInfoItem('Language', 'English'),
                        _buildInfoItem('Age Rating', _getFormattedRating(widget.movie.certification)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Watch Now Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () => _watchOnPlatform(widget.movie.title, widget.movie.isTv),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.movie.isTv ? Colors.orange : Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: (widget.movie.isTv ? Colors.orange : Colors.redAccent).withValues(alpha: 0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_circle_fill_rounded, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              widget.movie.isTv ? 'Watch on WeTV' : 'Watch on Netflix',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.movie.overview,
                      style: const TextStyle(color: Colors.white60, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    _buildCastSection(widget.movie.cast),
                    const SizedBox(height: 24),
                    _buildRelatedMoviesSection(provider.relatedMovies),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subLabel,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: isActive ? activeColor.withValues(alpha: 0.6) : Colors.white12,
                  width: 1.5,
                ),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Icon(
                icon,
                color: isActive ? activeColor : Colors.white60,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedMoviesSection(List<Movie> related) {
    if (related.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.movie.isTv ? 'Related Dramas' : 'Related Movies',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            itemBuilder: (context, index) {
              return MovieCard(
                movie: related[index],
                isHorizontal: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE3FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF88A4E8), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCastSection(List<Cast>? cast) {
    if (cast == null || cast.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Cast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            itemBuilder: (context, index) {
              return _buildCastItem(cast[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCastItem(Cast castMember) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        final isFav = provider.isFavoriteActor(castMember.id);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActorDetailPage(actorId: castMember.id, actorName: castMember.name),
              ),
            );
          },
          onLongPress: () {
            provider.toggleFavoriteActor(castMember);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isFav ? 'Removed from favorite actors' : 'Added to favorite actors'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        imageUrl: castMember.fullProfilePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.white10),
                        errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white30),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          provider.toggleFavoriteActor(castMember);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isFav ? 'Removed from favorite actors' : 'Added to favorite actors'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.redAccent : Colors.white70,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  castMember.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
