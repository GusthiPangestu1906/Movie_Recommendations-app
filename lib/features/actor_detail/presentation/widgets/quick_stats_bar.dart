import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/actor_detail_provider.dart';

class QuickStatsBar extends StatelessWidget {
  const QuickStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActorDetailProvider>(context);
    final actorDetails = provider.actorDetails;

    if (actorDetails == null) return const SizedBox.shrink();

    final bool isWikidata =
        actorDetails.id.toString().length >
        9; // Simple heuristic for hashed IDs

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildStatTile(
              Icons.cake_rounded,
              'BORN',
              actorDetails.birthday ?? 'N/A',
              const Color(0xFFFFAB40),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatTile(
              Icons.location_on_rounded,
              'FROM',
              actorDetails.placeOfBirth?.split(',').last.trim() ??
                  (isWikidata ? 'Wikidata' : 'N/A'),
              const Color(0xFF448AFF),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatTile(
              Icons.trending_up_rounded,
              'SOURCE',
              isWikidata
                  ? 'W-DATA'
                  : (actorDetails.popularity?.toStringAsFixed(1) ?? 'N/A'),
              const Color(0xFF64FFDA),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
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
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
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
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
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
}
