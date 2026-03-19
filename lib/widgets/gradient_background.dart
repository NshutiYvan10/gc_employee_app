import 'package:flutter/material.dart';
import 'package:gc_employee_app/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.meshBackground,
            ),
          ),

          // Top-left blob — soft blue
          Positioned(
            top: -80,
            left: -60,
            child: _GradientBlob(
              size: 280,
              colors: [
                AppColors.mistBlue.withValues(alpha: 0.7),
                AppColors.lavender.withValues(alpha: 0.3),
              ],
            ),
          ),

          // Top-right blob — warm peach
          Positioned(
            top: -40,
            right: -80,
            child: _GradientBlob(
              size: 240,
              colors: [
                AppColors.peach.withValues(alpha: 0.6),
                AppColors.blush.withValues(alpha: 0.3),
              ],
            ),
          ),

          // Center-left blob — lavender
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: -100,
            child: _GradientBlob(
              size: 260,
              colors: [
                AppColors.lavender.withValues(alpha: 0.5),
                AppColors.mistBlue.withValues(alpha: 0.2),
              ],
            ),
          ),

          // Center-right blob — sage
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            right: -70,
            child: _GradientBlob(
              size: 220,
              colors: [
                AppColors.sage.withValues(alpha: 0.6),
                AppColors.warmIvory.withValues(alpha: 0.3),
              ],
            ),
          ),

          // Bottom-center blob — blush
          Positioned(
            bottom: -60,
            left: MediaQuery.of(context).size.width * 0.2,
            child: _GradientBlob(
              size: 300,
              colors: [
                AppColors.blush.withValues(alpha: 0.5),
                AppColors.peach.withValues(alpha: 0.2),
              ],
            ),
          ),

          // Content
          child,
        ],
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GradientBlob({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
