import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/movie_provider.dart';
import '../providers/actor_detail_provider.dart';
import '../widgets/actor_header.dart';
import '../widgets/quick_stats_bar.dart';
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
        actorId: actorId,
      )..loadActorData(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0E1E),
        body: Consumer<ActorDetailProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingBasic) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF5C6AC4)),
              );
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
                          QuickStatsBar(),
                          const SizedBox(height: 32),
                          ActorBiography(),
                          const SizedBox(height: 32),
                          ActorFilmography(),
                          const SizedBox(height: 40),
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
