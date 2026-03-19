import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gc_employee_app/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final mapped = _mapStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: mapped.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mapped.foreground.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        mapped.label,
        style: GoogleFonts.urbanist(
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
          color: mapped.foreground,
        ),
      ),
    );
  }

  _StatusStyle _mapStatus(String status) {
    final normalized = status.toLowerCase().replaceAll(' ', '_');

    switch (normalized) {
      case 'approved':
      case 'completed':
      case 'resolved':
      case 'active':
        return _StatusStyle(
          label: _formatLabel(status),
          foreground: AppColors.success,
          background: AppColors.successLight,
        );
      case 'pending':
      case 'in_progress':
      case 'upcoming':
        return _StatusStyle(
          label: _formatLabel(status),
          foreground: AppColors.warning,
          background: AppColors.warningLight,
        );
      case 'rejected':
      case 'overdue':
      case 'cancelled':
        return _StatusStyle(
          label: _formatLabel(status),
          foreground: AppColors.error,
          background: AppColors.errorLight,
        );
      case 'draft':
      case 'not_eligible':
      default:
        return _StatusStyle(
          label: _formatLabel(status),
          foreground: AppColors.textSecondary,
          background: AppColors.divider,
        );
    }
  }

  String _formatLabel(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}

class _StatusStyle {
  final String label;
  final Color foreground;
  final Color background;

  const _StatusStyle({
    required this.label,
    required this.foreground,
    required this.background,
  });
}
