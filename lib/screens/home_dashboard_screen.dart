import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/metric_card.dart';
import 'package:gc_employee_app/widgets/section_header.dart';
import 'package:gc_employee_app/widgets/status_badge.dart';
import 'package:gc_employee_app/mock/mock_users.dart';
import 'package:gc_employee_app/mock/mock_travel.dart';
import 'package:gc_employee_app/mock/mock_announcements.dart';
import 'package:gc_employee_app/mock/mock_leave.dart';
import 'package:gc_employee_app/mock/mock_tickets.dart';
import 'package:gc_employee_app/mock/mock_approvals.dart';

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToLeave;
  final VoidCallback? onNavigateToTravel;
  final VoidCallback? onNavigateToExpenses;
  final VoidCallback? onNavigateToTickets;
  final VoidCallback? onNavigateToApprovals;
  final VoidCallback? onNavigateToAnnouncements;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateToProfile,
    this.onNavigateToLeave,
    this.onNavigateToTravel,
    this.onNavigateToExpenses,
    this.onNavigateToTickets,
    this.onNavigateToApprovals,
    this.onNavigateToAnnouncements,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoad();
  }

  void _simulateLoad() {
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  int get _openTicketCount {
    return MockTickets.tickets
        .where((t) =>
            t['status'] == 'open' || t['status'] == 'in_progress')
        .length;
  }

  bool get _isManager => MockUser.currentUser['role'] == 'manager';

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDateFull(String dateStr) {
    final date = DateTime.parse(dateStr);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _timeAgo(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _formatDate(dateStr);
  }

  IconData _approvalTypeIcon(String type) {
    switch (type) {
      case 'travel':
        return PhosphorIcons.airplaneTilt(PhosphorIconsStyle.fill);
      case 'expense':
        return PhosphorIcons.receipt(PhosphorIconsStyle.fill);
      case 'timeoff':
        return PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill);
      default:
        return PhosphorIcons.fileText(PhosphorIconsStyle.fill);
    }
  }

  Color _approvalTypeColor(String type) {
    switch (type) {
      case 'travel':
        return AppColors.primary;
      case 'expense':
        return AppColors.warning;
      case 'timeoff':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Subtle gradient blobs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.12),
                    AppColors.primaryLight.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentLight.withValues(alpha: 0.1),
                    AppColors.accentLight.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.info.withValues(alpha: 0.08),
                    AppColors.info.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isLoading
                  ? _buildShimmerContent()
                  : _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final user = MockUser.currentUser;
    final travelBudget = MockTravel.budget;
    final nextTrip = MockTravel.nextUpcomingTrip;
    final announcements = MockAnnouncements.announcements;
    final vacationDays =
        MockLeave.balances['vacation']!['available'] as int;
    final pendingApprovals = MockApprovals.pendingApprovals;

    return SingleChildScrollView(
      key: const ValueKey('content'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildWelcomeHeader(user),
          const SizedBox(height: 24),
          _buildMetricsGrid(vacationDays, travelBudget),
          const SizedBox(height: 24),
          _buildUpcomingTravel(nextTrip),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 28),
          _buildAnnouncements(announcements),
          if (_isManager) ...[
            const SizedBox(height: 28),
            _buildPendingApprovals(pendingApprovals),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Welcome Header
  // ---------------------------------------------------------------------------
  Widget _buildWelcomeHeader(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  _greeting,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user['preferredName']} ${(user['legalName'] as String).split(' ').last}',
                  style: GoogleFonts.urbanist(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${user['jobTitle']}  ·  ${user['department']}',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: widget.onNavigateToProfile,
            child: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user['avatarInitials'] as String,
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Quick Metrics (2x2 grid)
  // ---------------------------------------------------------------------------
  Widget _buildMetricsGrid(
    int vacationDays,
    Map<String, dynamic> travelBudget,
  ) {
    final remaining = travelBudget['remaining'] as double;
    final formattedBudget =
        '\$${remaining.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

    final metrics = <Widget>[
      MetricCard(
        icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
        label: 'PTO Balance',
        value: '$vacationDays days',
        color: AppColors.success,
        onTap: widget.onNavigateToLeave,
      ),
      MetricCard(
        icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
        label: 'Travel Budget',
        value: formattedBudget,
        color: AppColors.primary,
        trend: '${(travelBudget['percentUsed'] as double).toStringAsFixed(0)}% used',
        trendPositive: false,
        onTap: widget.onNavigateToTravel,
      ),
      MetricCard(
        icon: PhosphorIcons.headset(PhosphorIconsStyle.fill),
        label: 'Open Tickets',
        value: '$_openTicketCount',
        color: AppColors.warning,
        onTap: widget.onNavigateToTickets,
      ),
      if (_isManager)
        MetricCard(
          icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
          label: 'Pending Approvals',
          value: '${MockApprovals.pendingApprovals.length}',
          color: AppColors.accent,
          onTap: widget.onNavigateToApprovals,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: metrics.map((m) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 52) / 2,
            child: m,
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Upcoming Travel
  // ---------------------------------------------------------------------------
  Widget _buildUpcomingTravel(Map<String, dynamic> trip) {
    final departure = _formatDate(trip['departureDate'] as String);
    final returnDate = _formatDate(trip['returnDate'] as String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Upcoming Travel',
          onSeeAll: widget.onNavigateToTravel,
        ),
        const SizedBox(height: 4),
        GlassCard(
          onTap: widget.onNavigateToTravel,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  PhosphorIcons.airplaneTilt(PhosphorIconsStyle.fill),
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trip['destination'] as String,
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          status: trip['status'] as String,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trip['purpose'] as String,
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$departure - $returnDate',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Quick Actions
  // ---------------------------------------------------------------------------
  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        'Request Leave',
        PhosphorIcons.calendarPlus(PhosphorIconsStyle.fill),
        AppColors.success,
        widget.onNavigateToLeave,
      ),
      _QuickAction(
        'Submit Travel',
        PhosphorIcons.airplaneTakeoff(PhosphorIconsStyle.fill),
        AppColors.primary,
        widget.onNavigateToTravel,
      ),
      _QuickAction(
        'New Expense',
        PhosphorIcons.receipt(PhosphorIconsStyle.fill),
        AppColors.warning,
        widget.onNavigateToExpenses,
      ),
      _QuickAction(
        'Get Help',
        PhosphorIcons.headset(PhosphorIconsStyle.fill),
        AppColors.info,
        widget.onNavigateToTickets,
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final a = actions[i];
          return GestureDetector(
            onTap: () {
              if (a.onTap != null) {
                a.onTap!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${a.label} coming soon',
                      style: GoogleFonts.urbanist(fontWeight: FontWeight.w500),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: a.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: a.color.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(a.icon, size: 18, color: a.color),
                  const SizedBox(width: 8),
                  Text(
                    a.label,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: a.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Announcements
  // ---------------------------------------------------------------------------
  Widget _buildAnnouncements(List<Map<String, dynamic>> announcements) {
    final latest = announcements.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Announcements',
          onSeeAll: widget.onNavigateToAnnouncements,
        ),
        const SizedBox(height: 4),
        ...latest.map((a) => _buildAnnouncementCard(a)),
      ],
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final isUrgent = announcement['priority'] == 'urgent';
    final isUnread = announcement['isRead'] == false;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isUrgent || isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUrgent ? AppColors.error : AppColors.primary,
                  ),
                ),
              Expanded(
                child: Text(
                  announcement['title'] as String,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            announcement['snippet'] as String,
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mistBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  announcement['department'] as String,
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(announcement['date'] as String),
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pending Approvals (manager only)
  // ---------------------------------------------------------------------------
  Widget _buildPendingApprovals(List<Map<String, dynamic>> approvals) {
    final preview = approvals.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pending Approvals',
          onSeeAll: widget.onNavigateToApprovals,
        ),
        const SizedBox(height: 4),
        ...preview.map((a) => _buildApprovalCard(a)),
      ],
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> approval) {
    final type = approval['type'] as String;
    final amount = approval['amount'];
    final formattedAmount = amount != null
        ? '\$${(amount as double).toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
        : null;

    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _approvalTypeColor(type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _approvalTypeIcon(type),
              color: _approvalTypeColor(type),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        approval['employeeName'] as String,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (formattedAmount != null)
                      Text(
                        formattedAmount,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  approval['summary'] as String,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _timeAgo(approval['submittedDate'] as String),
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shimmer Loading State
  // ---------------------------------------------------------------------------
  Widget _buildShimmerContent() {
    return SingleChildScrollView(
      key: const ValueKey('shimmer'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(100, 14),
                      const SizedBox(height: 8),
                      _shimmerBox(180, 26),
                      const SizedBox(height: 8),
                      _shimmerBox(160, 13),
                    ],
                  ),
                ),
                _shimmerBox(52, 52, radius: 18),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Metrics shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                4,
                (_) => _shimmerBox(
                  (MediaQuery.of(context).size.width - 52) / 2,
                  68,
                  radius: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Travel card shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _shimmerBox(double.infinity, 120, radius: 20),
          ),
          const SizedBox(height: 28),
          // Quick actions shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                    child: _shimmerBox(double.infinity, 44, radius: 22),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Announcements shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _shimmerBox(140, 18),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _shimmerBox(double.infinity, 100, radius: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {double radius = 12}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.border.withValues(alpha: value),
                AppColors.divider.withValues(alpha: value * 0.6),
                AppColors.border.withValues(alpha: value),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Action Model
// ---------------------------------------------------------------------------
class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickAction(this.label, this.icon, this.color, this.onTap);
}
