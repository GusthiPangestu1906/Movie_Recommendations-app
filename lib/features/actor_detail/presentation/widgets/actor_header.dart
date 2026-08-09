import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../favorite/presentation/providers/favorite_provider.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../providers/actor_detail_provider.dart';

class ActorHeader extends StatelessWidget {
  const ActorHeader({super.key});

  void _launchSocial(BuildContext context, String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
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
                    Center(child: AppLoadingIndicator(size: 40)),
                errorWidget: (context, url, error) => Container(
                  height: 500,
                  color: Colors.white10,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white30,
                    size: 80,
                  ),
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
                      const Color(0xFF0B0E1E).withOpacity(0.8),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 16,
              child: _buildGlassButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Positioned(
              top: 20,
              right: 16,
              child: Consumer<FavoriteProvider>(
                builder: (context, favoriteProvider, child) {
                  final isFav = favoriteProvider.isFavoriteActor(actorId);
                  return _buildGlassButton(
                    icon: isFav ? Icons.favorite : Icons.favorite_border,
                    iconColor: isFav ? Colors.redAccent : Colors.white,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      favoriteProvider.toggleFavoriteActor(actorDetails);
                    },
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      actorDetails.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                  ),
                  if (actorDetails.instagramId != null &&
                      actorDetails.instagramId!.isNotEmpty)
                    GestureDetector(
                      onTap: () => _launchSocial(
                        context,
                        'https://instagram.com/${actorDetails.instagramId}',
                      ),
                      child: _buildBootstrapInstagramIcon(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
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
        'assets/Instagram_logo_2022.svg',
        width: 24,
        height: 24,
      ),
    );
  }
}
