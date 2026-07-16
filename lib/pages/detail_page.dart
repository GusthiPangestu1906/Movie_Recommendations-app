import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../providers/history_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'actor_detail_page.dart';
import '../widgets/shimmer_loading.dart';
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
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<MovieProvider>(context, listen: false).loadMovieExtras(widget.movie);
    });
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
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: child!,
            ),
          ),
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
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF0B0E1E),
                leadingWidth: 80,
                leading: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                actions: [
                  Consumer<HistoryProvider>(
                    builder: (context, history, _) {
                      final isWatched = history.isWatched(widget.movie.id);
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  if (isWatched) {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: const Color(0xFF1A1D2E),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                                      ),
                                      builder: (context) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 12),
                                          Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Watched History',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
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
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    );
                                  } else {
                                    _selectWatchDate(context);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isWatched ? Colors.green.withValues(alpha: 0.8) : Colors.black45,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isWatched ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.white10,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isWatched ? Icons.check_circle_rounded : Icons.add_task_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isWatched ? 'WATCHED' : 'MARK WATCHED',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.movie.fullBackdropPath,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerLoading(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: BorderRadius.zero,
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white10),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xFF0B0E1E),
                            ],
                            stops: [0.6, 1.0],
                          ),
                        ),
                      ),
                      if (widget.movie.trailerKey != null)
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _playTrailer(widget.movie.trailerKey);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1000.ms, curve: Curves.easeInOut),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      color: Colors.black.withValues(alpha: 0.24),
                                      child: const Text(
                                        'Play Trailer',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.movie.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                          ),
                          Row(
                            children: [
                              _AnimatedFavoriteButton(
                                isFavorite: provider.isFavorite(widget.movie.id),
                                onToggle: () => provider.toggleFavorite(widget.movie),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.movie.voteAverage.toStringAsFixed(1)} / 10 IMDb',
                            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildChip('ACTION'),
                          _buildChip('ADVENTURE'),
                          _buildChip('FANTASY'),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem('Length', '2h 28min'),
                            _buildInfoItem('Language', 'English'),
                            _buildInfoItem('Rating', _getFormattedRating(widget.movie.certification)),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                      const SizedBox(height: 32),
                      // Watch Now Button
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: GestureDetector(
                          onTapDown: (_) => HapticFeedback.mediumImpact(),
                          child: ElevatedButton(
                            onPressed: () => _watchOnPlatform(widget.movie.title, widget.movie.isTv),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.movie.isTv ? Colors.orange : Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
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
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                      const SizedBox(height: 36),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.movie.overview,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 32),
                      _buildCastSection(widget.movie.cast),
                      const SizedBox(height: 32),
                      _buildRelatedMoviesSection(provider.relatedMovies),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE3FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF88A4E8).withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF88A4E8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCastSection(List<Cast>? cast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: cast == null || cast.isEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 16),
                    child: const Column(
                      children: [
                        ShimmerLoading(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(30))),
                        SizedBox(height: 12),
                        ShimmerLoading(width: 50, height: 10),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: cast.length,
                  itemBuilder: (context, index) {
                    return _buildCastItem(cast[index])
                        .animate(delay: (index * 50).ms)
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.2);
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
          child: Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10, width: 2),
                      ),
                      child: ClipRRect(
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
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          provider.toggleFavoriteActor(castMember);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D2E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.white70,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  castMember.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRelatedMoviesSection(List<Movie> related) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.movie.isTv ? 'Related Dramas' : 'Related Movies',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: related.isEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => const MovieCardShimmer(isHorizontal: true),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: related.length,
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      child: MovieCard(
                        movie: related[index],
                        isHorizontal: true,
                      )
                          .animate(delay: (index * 100).ms)
                          .fadeIn(duration: 500.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AnimatedFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const _AnimatedFavoriteButton({
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onToggle();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation.drive(
              Tween<double>(begin: 0.7, end: 1.0).chain(
                CurveTween(curve: Curves.elasticOut),
              ),
            ),
            child: child,
          );
        },
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey<bool>(isFavorite),
          color: isFavorite ? Colors.redAccent : Colors.white70,
          size: 28,
        ),
      ),
    );
  }
}
