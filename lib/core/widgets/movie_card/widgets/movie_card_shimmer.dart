import 'package:flutter/material.dart';
import '../../common/loading/shimmer_loading.dart';

class MovieCardShimmer extends StatelessWidget {
  final bool isHorizontal;
  const MovieCardShimmer({super.key, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    return isHorizontal ? _buildHorizontalShimmer() : _buildStandardShimmer();
  }

  Widget _buildHorizontalShimmer() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ShimmerLoading(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(width: 100, height: 13),
                  SizedBox(height: 4),
                  ShimmerLoading(width: 50, height: 12),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardShimmer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            ShimmerLoading(
              width: 120,
              height: 180,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoading(width: double.infinity, height: 16),
                    const SizedBox(height: 12),
                    const ShimmerLoading(width: 100, height: 15),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ShimmerLoading(
                          width: 60,
                          height: 24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(width: 8),
                        ShimmerLoading(
                          width: 60,
                          height: 24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
