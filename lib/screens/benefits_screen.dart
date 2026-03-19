import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/gradient_background.dart';
import 'package:gc_employee_app/widgets/status_badge.dart';
import 'package:gc_employee_app/mock/mock_benefits.dart';

// ---------------------------------------------------------------------------
// Color accents per benefit type
// ---------------------------------------------------------------------------
class _BenefitTheme {
  final Color tint;
  final Color iconBackground;
  final Color accentColor;
  final PhosphorIconData icon;

  const _BenefitTheme({
    required this.tint,
    required this.iconBackground,
    required this.accentColor,
    required this.icon,
  });
}

_BenefitTheme _themeFor(String type) {
  switch (type) {
    case 'Health Insurance':
      return _BenefitTheme(
        tint: const Color(0xFFE8F5F2),
        iconBackground: const Color(0xFFCCEDE6),
        accentColor: const Color(0xFF2BA88C),
        icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.duotone),
      );
    case 'Dental Insurance':
      return _BenefitTheme(
        tint: const Color(0xFFE6F9F0),
        iconBackground: const Color(0xFFC4F0DA),
        accentColor: const Color(0xFF34B36A),
        icon: PhosphorIcons.tooth(PhosphorIconsStyle.duotone),
      );
    case 'Vision Insurance':
      return _BenefitTheme(
        tint: const Color(0xFFF0ECFA),
        iconBackground: const Color(0xFFDDD4F6),
        accentColor: const Color(0xFF8B6FD4),
        icon: PhosphorIcons.eyeglasses(PhosphorIconsStyle.duotone),
      );
    case 'Life Insurance':
      return _BenefitTheme(
        tint: const Color(0xFFFFF3EC),
        iconBackground: const Color(0xFFFFE0CA),
        accentColor: const Color(0xFFE08848),
        icon: PhosphorIcons.shield(PhosphorIconsStyle.duotone),
      );
    case 'Retirement':
      return _BenefitTheme(
        tint: const Color(0xFFFFF8E6),
        iconBackground: const Color(0xFFFFEBB3),
        accentColor: const Color(0xFFD4A017),
        icon: PhosphorIcons.piggyBank(PhosphorIconsStyle.duotone),
      );
    case 'Employee Assistance':
      return _BenefitTheme(
        tint: const Color(0xFFFCEDF3),
        iconBackground: const Color(0xFFF8D4E4),
        accentColor: const Color(0xFFD4568E),
        icon: PhosphorIcons.handHeart(PhosphorIconsStyle.duotone),
      );
    case 'Tuition Assistance':
      return _BenefitTheme(
        tint: const Color(0xFFE8F0FC),
        iconBackground: const Color(0xFFCCDDF8),
        accentColor: const Color(0xFF4A7FD4),
        icon: PhosphorIcons.graduationCap(PhosphorIconsStyle.duotone),
      );
    default:
      return _BenefitTheme(
        tint: AppColors.mistBlue,
        iconBackground: const Color(0xFFD6E0F5),
        accentColor: AppColors.primary,
        icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.duotone),
      );
  }
}

// ===========================================================================
// BenefitsScreen
// ===========================================================================
class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({super.key});

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  final Set<String> _expandedIds = {};

  void _toggle(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return GradientBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ---- Header ----
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding + 12,
                left: 20,
                right: 20,
                bottom: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'My Benefits',
                    style: GoogleFonts.urbanist(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your benefits overview \u2014 managed by Adventist Risk Management',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Open Enrollment Banner ----
          SliverToBoxAdapter(
            child: _OpenEnrollmentBanner(),
          ),

          // ---- Benefit Cards ----
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final benefit =
                    MockBenefits.benefits[index] as Map<String, dynamic>;
                final id = benefit['id'] as String;
                final type = benefit['type'] as String;
                final isExpanded = _expandedIds.contains(id);

                if (type == 'Retirement') {
                  return _RetirementCard(
                    benefit: benefit,
                    isExpanded: isExpanded,
                    onToggle: () => _toggle(id),
                  );
                }

                return _BenefitCard(
                  benefit: benefit,
                  isExpanded: isExpanded,
                  onToggle: () => _toggle(id),
                );
              },
              childCount: MockBenefits.benefits.length,
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ===========================================================================
// Open Enrollment Banner
// ===========================================================================
class _OpenEnrollmentBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B5EC9), Color(0xFF7C5CFC)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    PhosphorIcons.calendarCheck(PhosphorIconsStyle.duotone),
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open Enrollment: April 1\u201315, 2026',
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review and update your benefit elections',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Generic Benefit Card
// ===========================================================================
class _BenefitCard extends StatelessWidget {
  final Map<String, dynamic> benefit;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _BenefitCard({
    required this.benefit,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final type = benefit['type'] as String;
    final theme = _themeFor(type);
    final details = benefit['details'] as Map<String, dynamic>;
    final policyLast4 = benefit['policyNumberLast4'];

    return GlassCard(
      backgroundColor: theme.tint.withValues(alpha: 0.55),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.zero,
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Collapsed header ----
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBubble(
                      icon: theme.icon,
                      backgroundColor: theme.iconBackground,
                      iconColor: theme.accentColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.accentColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            benefit['planName'] as String,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: benefit['status'] as String),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  benefit['provider'] as String,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                // Key metrics row (collapsed summary)
                if (_keyMetrics(type, details).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _KeyMetricsRow(
                    metrics: _keyMetrics(type, details),
                    accentColor: theme.accentColor,
                  ),
                ],
              ],
            ),
          ),

          // ---- Expandable details ----
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _ExpandedDetails(
              details: details,
              type: type,
              accentColor: theme.accentColor,
              policyLast4: policyLast4,
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeInOut,
          ),

          // ---- Toggle row ----
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExpanded ? 'Hide Details' : 'View Full Details',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.accentColor,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: theme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_KeyMetric> _keyMetrics(String type, Map<String, dynamic> d) {
    switch (type) {
      case 'Health Insurance':
        return [
          _KeyMetric('Deductible', d['deductible']?.toString().split(' /').first ?? ''),
          _KeyMetric('Copay', d['copay']?.toString().split(' /').first ?? ''),
          _KeyMetric('Premium', d['premiumPerPaycheck'] ?? ''),
        ];
      case 'Dental Insurance':
        return [
          _KeyMetric('Annual Max', d['annualMaximum']?.toString().split(' per').first ?? ''),
          _KeyMetric('Deductible', d['deductible']?.toString().split(' /').first ?? ''),
          _KeyMetric('Premium', d['premiumPerPaycheck'] ?? ''),
        ];
      case 'Vision Insurance':
        return [
          _KeyMetric('Exam', d['examCopay']?.toString().split(' (').first ?? ''),
          _KeyMetric('Frames', d['lensesAllowance']?.toString().split(' /').first ?? ''),
          _KeyMetric('Premium', d['premiumPerPaycheck'] ?? ''),
        ];
      case 'Life Insurance':
        return [
          _KeyMetric('Basic', d['basicCoverage']?.toString().split(' (').first ?? ''),
          _KeyMetric('Supplemental', d['supplementalCoverage'] ?? ''),
        ];
      case 'Employee Assistance':
        return [
          _KeyMetric('Sessions', d['counselingSessions']?.toString().split(' per').first ?? ''),
          _KeyMetric('Cost', d['cost'] ?? ''),
        ];
      case 'Tuition Assistance':
        return [
          _KeyMetric('Employee', d['employeeBenefit']?.toString().split(' for').first ?? ''),
        ];
      default:
        return [];
    }
  }
}

// ===========================================================================
// Retirement Card (special/larger)
// ===========================================================================
class _RetirementCard extends StatelessWidget {
  final Map<String, dynamic> benefit;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _RetirementCard({
    required this.benefit,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor('Retirement');
    final details = benefit['details'] as Map<String, dynamic>;
    final policyLast4 = benefit['policyNumberLast4'];

    return GlassCard(
      backgroundColor: theme.tint.withValues(alpha: 0.6),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.zero,
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBubble(
                      icon: theme.icon,
                      backgroundColor: theme.iconBackground,
                      iconColor: theme.accentColor,
                      size: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Retirement',
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.accentColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            benefit['planName'] as String,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: benefit['status'] as String),
                  ],
                ),

                const SizedBox(height: 18),

                // ---- Estimated Balance (prominent) ----
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.accentColor.withValues(alpha: 0.08),
                        theme.accentColor.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Balance',
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        details['estimatedBalance'] as String,
                        style: GoogleFonts.urbanist(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: theme.accentColor,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'As of ${details['lastStatementDate']}',
                        style: GoogleFonts.urbanist(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ---- Vesting + Contribution row ----
                Row(
                  children: [
                    // Vesting status
                    Expanded(
                      child: _RetirementMetricTile(
                        label: 'Vesting',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIcons.checkCircle(
                                  PhosphorIconsStyle.fill),
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              details['vestingStatus'] as String,
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Contribution
                    Expanded(
                      child: _RetirementMetricTile(
                        label: 'Contribution',
                        child: Text(
                          '5% + 5% match',
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ---- Investment Allocation Bar ----
                _AllocationBar(
                  allocation: details['investmentAllocation'] as String,
                  accentColor: theme.accentColor,
                ),
              ],
            ),
          ),

          // ---- Expandable details ----
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _ExpandedDetails(
              details: details,
              type: 'Retirement',
              accentColor: theme.accentColor,
              policyLast4: policyLast4,
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeInOut,
          ),

          // ---- Toggle ----
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExpanded ? 'Hide Details' : 'View Full Details',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.accentColor,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: theme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Shared sub-widgets
// ===========================================================================

class _IconBubble extends StatelessWidget {
  final PhosphorIconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const _IconBubble({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.52),
    );
  }
}

class _KeyMetric {
  final String label;
  final String value;
  const _KeyMetric(this.label, this.value);
}

class _KeyMetricsRow extends StatelessWidget {
  final List<_KeyMetric> metrics;
  final Color accentColor;

  const _KeyMetricsRow({
    required this.metrics,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: metrics.asMap().entries.map((entry) {
          final metric = entry.value;
          final isLast = entry.key == metrics.length - 1;
          return Expanded(
            child: Container(
              decoration: !isLast
                  ? BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: accentColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                    )
                  : null,
              padding: EdgeInsets.only(right: isLast ? 0 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    metric.label,
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RetirementMetricTile extends StatelessWidget {
  final String label;
  final Widget child;

  const _RetirementMetricTile({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _AllocationBar extends StatelessWidget {
  final String allocation;
  final Color accentColor;

  const _AllocationBar({
    required this.allocation,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Parse "60% Equity / 30% Bond / 10% Stable Value"
    final segments = allocation.split(' / ');
    final parsed = <_AllocSegment>[];
    final colors = [
      const Color(0xFF3B5EC9),
      const Color(0xFF34C759),
      const Color(0xFFFFB830),
    ];

    for (int i = 0; i < segments.length; i++) {
      final parts = segments[i].trim().split('% ');
      if (parts.length == 2) {
        final pct = double.tryParse(parts[0]) ?? 0;
        parsed.add(_AllocSegment(
          label: parts[1],
          percent: pct,
          color: colors[i % colors.length],
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Allocation',
          style: GoogleFonts.urbanist(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: parsed.asMap().entries.map((e) {
                final seg = e.value;
                return Expanded(
                  flex: seg.percent.round(),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: e.key < parsed.length - 1 ? 2 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: seg.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: parsed.map((seg) {
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: seg.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${seg.percent.round()}% ${seg.label}',
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AllocSegment {
  final String label;
  final double percent;
  final Color color;
  const _AllocSegment({
    required this.label,
    required this.percent,
    required this.color,
  });
}

// ===========================================================================
// Expanded Details Section
// ===========================================================================
class _ExpandedDetails extends StatelessWidget {
  final Map<String, dynamic> details;
  final String type;
  final Color accentColor;
  final String? policyLast4;

  const _ExpandedDetails({
    required this.details,
    required this.type,
    required this.accentColor,
    this.policyLast4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: accentColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),
          Text(
            'Full Details',
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...details.entries.map((entry) {
            final value = entry.value;
            if (value is List) {
              return _DetailListItem(
                label: _formatKey(entry.key),
                items: value.cast<String>(),
                accentColor: accentColor,
              );
            }
            if (value is bool) {
              return _DetailRow(
                label: _formatKey(entry.key),
                value: value ? 'Yes' : 'No',
              );
            }
            return _DetailRow(
              label: _formatKey(entry.key),
              value: value.toString(),
            );
          }),
          if (policyLast4 != null) ...[
            const SizedBox(height: 4),
            _DetailRow(
              label: 'Policy #',
              value: '****$policyLast4',
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    // camelCase -> Title Case
    final buffer = StringBuffer();
    for (int i = 0; i < key.length; i++) {
      final char = key[i];
      if (char == char.toUpperCase() && i > 0 && key[i - 1] != key[i - 1].toUpperCase()) {
        buffer.write(' ');
      }
      buffer.write(i == 0 ? char.toUpperCase() : char);
    }
    return buffer.toString();
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailListItem extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color accentColor;

  const _DetailListItem({
    required this.label,
    required this.items,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
