import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/auth_provider.dart';
import '../../../tv/presentation/providers/tv_provider.dart';
import '../../../../pages/actors_page.dart';
import '../providers/home_provider.dart';
import 'profile_sheet.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final user = authProvider.user;
    final isDramaMode = homeProvider.isDramaMode;

    return Drawer(
      backgroundColor: const Color(0xFF0B0E1E),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A1D2E)),
            currentAccountPicture: GestureDetector(
              onTap: () => _showEditProfile(context),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF5C6AC4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF1A1D2E),
                      radius: 36,
                      backgroundImage: authProvider.photoUrl != null
                          ? CachedNetworkImageProvider(authProvider.photoUrl!)
                          : null,
                      child: authProvider.photoUrl == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white30,
                              size: 40,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5C6AC4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            accountName: Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              user?.email ?? 'guest@nyxdex.app',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.movie_filter,
            label: 'Movie Universe',
            isSelected: !isDramaMode,
            onTap: () {
              homeProvider.setDramaMode(false);
              homeProvider.setIndex(0);
              Provider.of<TvProvider>(
                context,
                listen: false,
              ).setDramaMode(false);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.tv,
            label: 'Drama Universe',
            isSelected: isDramaMode,
            onTap: () {
              homeProvider.setDramaMode(true);
              homeProvider.setIndex(0);
              Provider.of<TvProvider>(
                context,
                listen: false,
              ).setDramaMode(true);
              Navigator.pop(context);
            },
          ),
          const Divider(color: Colors.white10, height: 40),
          _buildDrawerItem(
            context: context,
            icon: Icons.people_outline,
            label: 'Favorite Stars',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteActorsPage(),
                ),
              );
            },
          ),
          const Spacer(),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            label: 'Logout',
            onTap: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const ProfileSheet(),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF5C6AC4) : Colors.white30,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
    );
  }
}
