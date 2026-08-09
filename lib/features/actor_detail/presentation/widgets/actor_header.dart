import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../favorite/presentation/providers/favorite_provider.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../providers/actor_detail_provider.dart';

class ActorHeader extends StatefulWidget {
  const ActorHeader({super.key});

  @override
  State<ActorHeader> createState() => _ActorHeaderState();
}

class _ActorHeaderState extends State<ActorHeader> {
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActorDetailProvider>(context);
    final actorDetails = provider.actorDetails;
    final actorId = provider.actorId;

    if (actorDetails == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        0,
      ),
      height: 500,
      child: Stack(
        children: [
          // 1. FLIPPING CONTENT (Only the card flips)
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != 0) {
                HapticFeedback.mediumImpact();
                setState(() => _isFlipped = !_isFlipped);
              }
            },
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              tween: Tween<double>(begin: 0, end: _isFlipped ? 180 : 0),
              builder: (context, double value, child) {
                final isBack = value >= 90;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(value * (math.pi / 180)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: isBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _buildBackSide(actorDetails),
                            )
                          : _buildFrontSide(actorDetails, actorId),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. FIXED CONTROLS (Buttons stay here, they do NOT flip)
          _buildFixedControls(context, actorDetails, actorId),

          // 3. FIXED SWIPE HINT (Stays in corner)
          Positioned(
            bottom: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _isFlipped = !_isFlipped);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Icon(
                  _isFlipped
                      ? Icons.swipe_left_rounded
                      : Icons.swipe_right_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontSide(dynamic actorDetails, int actorId) {
    return Stack(
      children: [
        Hero(
          tag: 'actor-backdrop-$actorId',
          child: CachedNetworkImage(
            imageUrl: actorDetails.fullProfilePathHD,
            width: double.infinity,
            height: 500,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            placeholder: (context, url) =>
                const Center(child: AppLoadingIndicator(size: 40)),
            errorWidget: (context, url, error) => Container(
              height: 500,
              color: Colors.white10,
              child: const Icon(Icons.person, color: Colors.white30, size: 80),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF0B0E1E).withOpacity(0.95),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 70,
          child: Text(
            actorDetails.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackSide(dynamic actorDetails) {
    return Container(
      color: const Color(0xFF0B0E1E),
      child: Stack(
        children: [
          // Deep Blur Background
          CachedNetworkImage(
            imageUrl: actorDetails.fullProfilePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 500,
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0B0E1E).withOpacity(0.85),
                      const Color(0xFF0B0E1E).withOpacity(0.98),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Info Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 4),
                // Actor Profile Circle (Small)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: actorDetails.fullProfilePath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  actorDetails.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Text(
                    'ACTOR PROFILE',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildBackStat(
                  Icons.cake_rounded,
                  'BORN',
                  actorDetails.birthday ?? 'N/A',
                  const Color(0xFFFFAB40),
                ),
                const SizedBox(height: 10),
                _buildBackStat(
                  Icons.location_on_rounded,
                  'FROM',
                  actorDetails.placeOfBirth?.split(',').last.trim() ?? 'N/A',
                  const Color(0xFF448AFF),
                ),
                const SizedBox(height: 10),
                _buildBackStat(
                  Icons.trending_up_rounded,
                  'POPULARITY',
                  actorDetails.popularity?.toStringAsFixed(1) ?? 'N/A',
                  const Color(0xFF64FFDA),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackStat(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedControls(
    BuildContext context,
    dynamic actorDetails,
    int actorId,
  ) {
    return Positioned(
      top: 24,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).pop(),
          ),
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              final isFav = favoriteProvider.isFavoriteActor(actorId);
              return _buildGlassButton(
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                iconColor: isFav ? Colors.redAccent : Colors.white,
                onTap: () => favoriteProvider.toggleFavoriteActor(actorDetails),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}
