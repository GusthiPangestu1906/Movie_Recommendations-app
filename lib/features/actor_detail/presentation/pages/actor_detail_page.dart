import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../movie/presentation/providers/movie_provider.dart';
import '../../../favorite/presentation/providers/favorite_provider.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../providers/actor_detail_provider.dart';
import '../widgets/actor_header.dart';
import '../widgets/actor_biography.dart';
import '../widgets/actor_filmography.dart';

class ActorDetailPage extends StatelessWidget {
  final int actorId;
  final String actorName;

  const ActorDetailPage({
    super.key,
    required this.actorId,
    required this.actorName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ActorDetailProvider(
        movieProvider: Provider.of<MovieProvider>(context, listen: false),
        favoriteProvider: Provider.of<FavoriteProvider>(context, listen: false),
        searchProvider: Provider.of<SearchProvider>(context, listen: false),
        actorId: actorId,
      )..loadActorData(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0E1E),
        body: Consumer<ActorDetailProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingBasic) {
              return const Center(child: AppLoadingIndicator());
            }

            if (provider.actorDetails == null) {
              return const Center(
                child: Text(
                  'Failed to load actor details',
                  style: TextStyle(color: Colors.white38),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: ActorHeader()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          // QuickStatsBar removed as it's now on the back of the photo card
                          SizedBox(height: 10),
                          ActorBiography(),
                          SizedBox(height: 32),
                          ActorFilmography(),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
