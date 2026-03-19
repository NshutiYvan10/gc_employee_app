import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/section_header.dart';
import 'package:gc_employee_app/widgets/status_badge.dart';
import 'package:gc_employee_app/widgets/gradient_button.dart';
import 'package:gc_employee_app/mock/mock_travel.dart';

class TravelBudgetScreen extends StatelessWidget {
  const TravelBudgetScreen({super.key});

  static const _spent = Color(0xFF3B5EC9);
  static const _encumbered = Color(0xFFFFB830);
  static const _remaining = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final budget = MockTravel.budget;
    final trips = MockTravel.trips;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.meshBackground),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(context, budget['fiscalYear'] as String),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 120),
                  children: [
                    _buildDonutChartCard(budget),
                    const SizedBox(height: 4),
                    _buildBreakdownBarCard(budget),
                    const SizedBox(height: 12),
                    const SectionHeader(title: 'Trip History'),
                    const SizedBox(height: 4),
                    ...trips.map((trip) => _buildTripCard(trip)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildAppBar(BuildContext context, String fiscalYear) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: const Icon(
                PhosphorIconsBold.caretLeft,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Travel Budget',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'FY $fiscalYear',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(Map<String, Object> budget) {
    final spent = budget['spent'] as double;
    final encumbered = budget['encumbered'] as double;
    final remaining = budget['remaining'] as double;
    final annualBudget = budget['annualBudget'] as double;

    return GlassCard(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 55,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: spent,
                        color: _spent,
                        radius: 25,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: encumbered,
                        color: _encumbered,
                        radius: 25,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: remaining,
                        color: _remaining,
                        radius: 25,
                        showTitle: false,
                      ),
                    ],
                    borderData: FlBorderData(show: false),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${_formatCurrency(remaining)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available',
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem('Spent', spent, _spent),
              _legendItem('Encumbered', encumbered, _encumbered),
              _legendItem('Remaining', remaining, _remaining),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Center(
              child: Text(
                '\$${_formatCurrency(annualBudget)} Annual Budget',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, double amount, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\$${_formatCurrency(amount)}',
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownBarCard(Map<String, Object> budget) {
    final spent = budget['spent'] as double;
    final encumbered = budget['encumbered'] as double;
    final remaining = budget['remaining'] as double;
    final annualBudget = budget['annualBudget'] as double;
    final percentUsed = budget['percentUsed'] as double;

    final spentFraction = spent / annualBudget;
    final encumberedFraction = encumbered / annualBudget;
    final remainingFraction = remaining / annualBudget;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Breakdown',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: percentUsed >= 80
                      ? AppColors.errorLight
                      : percentUsed >= 60
                          ? AppColors.warningLight
                          : AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentUsed.toStringAsFixed(1)}% used',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: percentUsed >= 80
                        ? AppColors.error
                        : percentUsed >= 60
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Flexible(
                    flex: (spentFraction * 1000).round(),
                    child: Container(color: _spent),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    flex: (encumberedFraction * 1000).round(),
                    child: Container(color: _encumbered),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    flex: (remainingFraction * 1000).round(),
                    child: Container(color: _remaining),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _barLabel('Spent', spent, _spent),
              ),
              Expanded(
                child: _barLabel('Encumbered', encumbered, _encumbered),
              ),
              Expanded(
                child: _barLabel('Remaining', remaining, _remaining),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barLabel(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '\$${_formatCurrency(amount)}',
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(Map<String, Object?> trip) {
    final purpose = trip['purpose'] as String;
    final destination = trip['destination'] as String;
    final departureDate = trip['departureDate'] as String;
    final returnDate = trip['returnDate'] as String;
    final status = trip['status'] as String;
    final estimatedCost = trip['estimatedCost'] as double;
    final actualCost = trip['actualCost'] as double?;
    final rejectionReason = trip['rejectionReason'] as String?;

    final dateRange = _formatDateRange(departureDate, returnDate);
    final isCompleted = status == 'completed';
    final displayCost = isCompleted && actualCost != null ? actualCost : estimatedCost;
    final costLabel = isCompleted && actualCost != null ? 'Actual' : 'Estimated';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purpose,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.mapPin,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination,
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.calendarBlank,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateRange,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_formatCurrency(displayCost)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      costLabel,
                      style: GoogleFonts.urbanist(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (status == 'rejected' && rejectionReason != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIconsRegular.warningCircle,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rejectionReason,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: GradientButton(
        text: 'Submit New Request',
        icon: PhosphorIconsBold.airplaneTilt,
        onPressed: () {},
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
    }
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
    return '$whole.${parts[1]}';
  }

  String _formatDateRange(String departure, String returnDate) {
    final dep = DateTime.parse(departure);
    final ret = DateTime.parse(returnDate);

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    if (dep.year == ret.year && dep.month == ret.month) {
      return '${months[dep.month - 1]} ${dep.day}-${ret.day}, ${dep.year}';
    } else if (dep.year == ret.year) {
      return '${months[dep.month - 1]} ${dep.day} - ${months[ret.month - 1]} ${ret.day}, ${dep.year}';
    }
    return '${months[dep.month - 1]} ${dep.day}, ${dep.year} - ${months[ret.month - 1]} ${ret.day}, ${ret.year}';
  }
}
