import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/actor_detail_provider.dart';

class ActorBiography extends StatelessWidget {
  const ActorBiography({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActorDetailProvider>(context);
    final actorDetails = provider.actorDetails;

    if (actorDetails == null) return const SizedBox.shrink();

    final bio = actorDetails.biography?.isNotEmpty == true
        ? actorDetails.biography!
        : 'No biography available for this actor.';

    final bool canExpand = bio.length > 300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Biography',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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
            style: const TextStyle(
              color: Colors.white70,
              height: 1.6,
              fontSize: 15,
            ),
          ),
          secondChild: Text(
            bio,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.6,
              fontSize: 15,
            ),
          ),
          crossFadeState: provider.isBiographyExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ).animate().fadeIn(delay: 400.ms),
        if (canExpand)
          GestureDetector(
            onTap: () => provider.toggleBiography(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    provider.isBiographyExpanded
                        ? 'Show Less'
                        : 'Read Full Bio',
                    style: const TextStyle(
                      color: Color(0xFF5C6AC4),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    provider.isBiographyExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
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
}
