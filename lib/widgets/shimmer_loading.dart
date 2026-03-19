import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gc_employee_app/theme/app_colors.dart';

class ShimmerCard extends StatelessWidget {
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.borderRadius = 20,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.surface,
      child: Container(
        height: height,
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.surface,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.divider,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
