import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _ShimmerContent(progress: _controller.value);
      },
    );
  }
}

class _ShimmerContent extends StatelessWidget {
  final double progress;

  const _ShimmerContent({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBar(width: 200),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, __) => _ProductCardShimmer(progress: progress),
            ),
          ),
          const SizedBox(height: 24),
          _shimmerBar(width: 160),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, __) => _ProductCardShimmer(progress: progress),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBar({double width = double.infinity}) {
    return Container(
      width: width,
      height: 20,
      decoration: BoxDecoration(
        color: _shimmerColor(progress),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ProductCardShimmer extends StatelessWidget {
  final double progress;

  const _ProductCardShimmer({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _shimmerColor(progress),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _shimmerColor(progress),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 14,
            width: 60,
            decoration: BoxDecoration(
              color: _shimmerColor(progress),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            width: 80,
            decoration: BoxDecoration(
              color: _shimmerColor(progress),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

Color _shimmerColor(double progress) {
  final base = VibeColors.navy.withValues(alpha: 0.08);
  final highlight = VibeColors.navy.withValues(alpha: 0.15);
  return Color.lerp(base, highlight, (progress * 2).clamp(0.0, 1.0))!;
}
