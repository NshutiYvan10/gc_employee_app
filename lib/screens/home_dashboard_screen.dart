import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
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

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Timer(const Duration(milliseconds: 750), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int get _openTicketCount => MockTickets.tickets
      .where((t) => t['status'] == 'open' || t['status'] == 'in_progress')
      .length;

  bool get _isManager => MockUser.currentUser['role'] == 'manager';

  String _fmt(String iso) {
    final d = DateTime.parse(iso);
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.day}';
  }

  String _timeAgo(String iso) {
    final diff = DateTime.now().difference(DateTime.parse(iso));
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _fmt(iso);
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'travel':  return AppColors.primary;
      case 'expense': return AppColors.gold;
      case 'timeoff': return AppColors.success;
      default:        return AppColors.textSecondary;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Dark hero colour as scaffold bg so top-bounce overscroll looks seamless
        backgroundColor: const Color(0xFF0E1E32),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          child: _isLoading ? _buildSkeleton() : _buildContent(),
        ),
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    final user          = MockUser.currentUser;
    final budget        = MockTravel.budget;
    final nextTrip      = MockTravel.nextUpcomingTrip;
    final announcements = MockAnnouncements.announcements;
    final vacDays       = MockLeave.balances['vacation']!['available'] as int;
    final vacUsed       = MockLeave.balances['vacation']!['used'] as int;
    final pendingList   = MockApprovals.pendingApprovals;

    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        key: const ValueKey('content'),
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Single sliver: hero gradient wraps everything including the white
          // sheet. The gradient naturally fills behind the sheet's rounded
          // top corners — no Transform, no backing strip, no tricks needed.
          SliverToBoxAdapter(
            child: _buildFullPage(
              user: user,
              vacDays: vacDays,
              vacUsed: vacUsed,
              budget: budget,
              nextTrip: nextTrip,
              announcements: announcements.take(3).toList(),
              pendingList: pendingList,
            ),
          ),
        ],
      ),
    );
  }

  // ── Full page: hero gradient wraps everything including the white sheet ──────
  //  The white sheet sits INSIDE the gradient Container, so the gradient
  //  naturally fills behind the sheet's rounded top corners. No Transform,
  //  no backing strip, no tricks — just parent-child nesting.
  Widget _buildFullPage({
    required Map<String, dynamic> user,
    required int vacDays,
    required int vacUsed,
    required Map<String, dynamic> budget,
    required Map<String, dynamic> nextTrip,
    required List<Map<String, dynamic>> announcements,
    required List<Map<String, dynamic>> pendingList,
  }) {
    final topPad = MediaQuery.of(context).padding.top;
    final name   = (user['preferredName'] as String).split(' ').first;
    final approvalCount = pendingList.length;

    return Stack(
      children: [
        // ── Main gradient container (wraps hero + white sheet)
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E1E32), Color(0xFF264567), Color(0xFF1E4A72)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero content ─────────────────────────────────────────────
              SizedBox(height: topPad + 20),

              // Top row: greeting + avatar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting,'.toUpperCase(),
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$name.',
                            style: GoogleFonts.urbanist(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user['jobTitle'] as String,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.60),
                            ),
                          ),
                          Text(
                            '${user['department']} Department',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.38),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: widget.onNavigateToProfile,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFC9A227), Color(0xFFE8C84B)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user['avatarInitials'] as String,
                            style: GoogleFonts.urbanist(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Stats bar + white sheet overlap zone ──────────────────
              //  The stats bar has 34px of extra bottom padding so its
              //  frosted background extends well past its content.
              //  The white sheet is pulled UP 30px via Transform.translate
              //  so its rounded top corners land ON TOP of the stats bar's
              //  extended bottom — the frosted background fills those corner
              //  voids perfectly. No gaps, no artifacts.
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                child: Container(
                  width: double.infinity,
                  // 34px bottom padding extends the frosted bg below content
                  padding: const EdgeInsets.only(bottom: 34),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.17),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.28),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _heroStat(
                        icon: LucideIcons.calendar,
                        label: 'PTO Left',
                        value: '$vacDays',
                        unit: 'days available',
                      ),
                      _heroStatDivider(),
                      _heroStat(
                        icon: LucideIcons.headphones,
                        label: 'Open Tickets',
                        value: '$_openTicketCount',
                        unit: 'active now',
                      ),
                      if (_isManager) ...[
                        _heroStatDivider(),
                        _heroStat(
                          icon: LucideIcons.checkCircle,
                          label: 'Approvals',
                          value: '$approvalCount',
                          unit: 'pending review',
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // White sheet pulled UP so it overlaps the stats bar's
              // extended bottom. The frosted bg fills behind the corners.
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      // ── Ambient colour blobs (subtle — just enough to tint
                      //    BackdropFilter glass cards, not visible on their own)
                      _ambientBlob(top: 80,  left: -60, size: 340, color: AppColors.primary, opacity: 0.06),
                      _ambientBlob(top: 320, right: -40, size: 280, color: AppColors.gold,   opacity: 0.05),
                      _ambientBlob(top: 620, left: 20,  size: 240, color: AppColors.success, opacity: 0.04),

                      // ── All content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          _buildFocusRail(vacDays, vacUsed, budget),
                          const SizedBox(height: 30),
                          _buildSectionRow('Next Journey', null),
                          const SizedBox(height: 14),
                          _buildNextJourney(nextTrip),
                          const SizedBox(height: 30),
                          _buildSectionRow('Quick Actions', null),
                          const SizedBox(height: 14),
                          _buildQuickActions(),
                          const SizedBox(height: 34),
                          _buildSectionRow('Announcements', widget.onNavigateToAnnouncements),
                          const SizedBox(height: 16),
                          _buildAnnouncementsFeed(announcements),
                          if (_isManager) ...[
                            const SizedBox(height: 34),
                            _buildApprovalsHeader(MockApprovals.pendingApprovals.length),
                            const SizedBox(height: 16),
                            _buildApprovalsCard(pendingList.take(3).toList()),
                          ],
                          const SizedBox(height: 52),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ),  // close Transform.translate
            ],
          ),
        ),

        // Decorative rings in hero background
        Positioned(
          top: -50, right: -40,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
                width: 40,
              ),
            ),
          ),
        ),
        Positioned(
          top: 30, right: 80,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.08),
                width: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ambientBlob({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildHero removed — merged into _buildFullPage above.

  // FIX 1: Premium stat item — label at top in gold, big number centre-stage,
  //         unit + ghost icon anchored at the bottom. Left-aligned, generous padding.
  Widget _heroStat({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label — gold, small-caps feel
            Text(
              label.toUpperCase(),
              style: GoogleFonts.urbanist(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            // Value — the hero element
            Text(
              value,
              style: GoogleFonts.urbanist(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            // Unit + ghost icon on the same row
            Row(
              children: [
                Expanded(
                  child: Text(
                    unit,
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.42),
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStatDivider() => Container(
        width: 1,
        height: 52,
        color: Colors.white.withValues(alpha: 0.14),
      );

  // ── 2. FOCUS CARDS RAIL ───────────────────────────────────────────────────────
  Widget _buildFocusRail(int vacDays, int vacUsed, Map<String, dynamic> budget) {
    final remaining   = budget['remaining'] as double;
    final pctUsed     = (budget['percentUsed'] as double) / 100;
    final vacProgress = vacUsed / (vacUsed + vacDays);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'YOUR OVERVIEW',
            style: GoogleFonts.urbanist(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 158,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _focusCard(
                label: 'PTO Balance',
                value: '$vacDays',
                unit: 'days left',
                sub: '$vacUsed days used',
                icon: LucideIcons.calendar,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF177A4A), Color(0xFF2EB86E)],
                ),
                progress: vacProgress,
                onTap: widget.onNavigateToLeave,
              ),
              const SizedBox(width: 14),
              _focusCard(
                label: 'Travel Budget',
                value: '\$${remaining.toStringAsFixed(0)}',
                unit: 'remaining',
                sub: '${(pctUsed * 100).toStringAsFixed(0)}% utilized',
                icon: LucideIcons.wallet,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0E1E32), Color(0xFF264567)],
                ),
                progress: pctUsed,
                onTap: widget.onNavigateToTravel,
              ),
              const SizedBox(width: 14),
              _focusCard(
                label: 'Open Tickets',
                value: '$_openTicketCount',
                unit: 'active',
                sub: 'IT support requests',
                icon: LucideIcons.headphones,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8A6A10), Color(0xFFC9A227)],
                ),
                progress: null,
                onTap: widget.onNavigateToTickets,
              ),
              if (_isManager) ...[
                const SizedBox(width: 14),
                _focusCard(
                  label: 'Pending',
                  value: '${MockApprovals.pendingApprovals.length}',
                  unit: 'approvals',
                  sub: 'Awaiting review',
                  icon: LucideIcons.checkCircle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF264567), Color(0xFF4A7FB5)],
                  ),
                  progress: null,
                  onTap: widget.onNavigateToApprovals,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _focusCard({
    required String label,
    required String value,
    required String unit,
    required String sub,
    required IconData icon,
    required LinearGradient gradient,
    required double? progress,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 15, color: Colors.white),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.urbanist(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            Text(
              unit,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 7),
            if (progress != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.20),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3.5,
                ),
              ),
              const SizedBox(height: 5),
            ],
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.50),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. NEXT JOURNEY — glass card ──────────────────────────────────────────────
  Widget _buildNextJourney(Map<String, dynamic> trip) {
    final approved = trip['status'] == 'approved';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: widget.onNavigateToTravel,
        // Glass card — shadow on outer, blur on inner
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  // Slightly blue-tinted white so it reads as glass, not just white
                  color: const Color(0xF2FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Subtle right-side accent wash
                    Positioned(
                      right: 0, top: 0, bottom: 0,
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              AppColors.primary.withValues(alpha: 0.04),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'NEXT TRIP',
                                style: GoogleFonts.urbanist(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textTertiary,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: approved
                                      ? AppColors.successLight
                                      : AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5, height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: approved
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      approved ? 'Approved' : 'Pending',
                                      style: GoogleFonts.urbanist(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: approved
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trip['destination'] as String,
                            style: GoogleFonts.urbanist(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                              letterSpacing: -0.6,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          _tripMeta(
                            LucideIcons.calendarRange,
                            '${_fmt(trip['departureDate'] as String)}  –  ${_fmt(trip['returnDate'] as String)}',
                          ),
                          const SizedBox(height: 5),
                          _tripMeta(
                            LucideIcons.briefcase,
                            trip['purpose'] as String,
                            clip: true,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 14, bottom: 14,
                      child: Transform.rotate(
                        angle: -0.18,
                        child: Icon(
                          LucideIcons.plane,
                          size: 38,
                          color: AppColors.primary.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tripMeta(IconData icon, String text, {bool clip = false}) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: clip ? 1 : null,
            overflow: clip ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }

  // ── 4. QUICK ACTIONS ──────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _Action('Request Leave', LucideIcons.calendarPlus, AppColors.success,  widget.onNavigateToLeave),
      _Action('Book Travel',   LucideIcons.planeTakeoff, AppColors.primary,  widget.onNavigateToTravel),
      _Action('New Expense',   LucideIcons.receipt,      AppColors.gold,     widget.onNavigateToExpenses),
      _Action('Get Support',   LucideIcons.headphones,   AppColors.info,     widget.onNavigateToTickets),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final a = actions[i];
          return GestureDetector(
            onTap: a.onTap ?? () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: a.color.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: a.color.withValues(alpha: 0.20),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(a.icon, size: 15, color: a.color),
                  const SizedBox(width: 7),
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

  // ── Section row header ────────────────────────────────────────────────────────
  Widget _buildSectionRow(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (onSeeAll != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(LucideIcons.arrowRight,
                      size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 5. ANNOUNCEMENTS ──────────────────────────────────────────────────────────
  Widget _buildAnnouncementsFeed(List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: items.asMap().entries.map((e) {
          return _announcementRow(e.value, showDivider: e.key < items.length - 1);
        }).toList(),
      ),
    );
  }

  Widget _announcementRow(Map<String, dynamic> ann, {required bool showDivider}) {
    final urgent   = ann['priority'] == 'urgent';
    final unread   = ann['isRead'] == false;
    final barColor = urgent ? AppColors.error : AppColors.primary;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3.5,
                decoration: BoxDecoration(
                  color: unread ? barColor : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ann['department'] as String,
                              style: GoogleFonts.urbanist(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (urgent) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'URGENT',
                                style: GoogleFonts.urbanist(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            _timeAgo(ann['date'] as String),
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ann['title'] as String,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ann['snippet'] as String,
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
        ] else
          const SizedBox(height: 4),
      ],
    );
  }

  // ── 6. MANAGER: PENDING APPROVALS ─────────────────────────────────────────────
  Widget _buildApprovalsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            'Pending Approvals',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onNavigateToApprovals,
            child: Row(
              children: [
                Text(
                  'See all',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(LucideIcons.arrowRight,
                    size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIX 3: Approvals card also gets the glass treatment
  Widget _buildApprovalsCard(List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.09),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xF4FFFFFF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  width: 1,
                ),
              ),
              child: Column(
                children: items.asMap().entries.map((e) {
                  return _approvalRow(e.value,
                      showDivider: e.key < items.length - 1);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _approvalRow(Map<String, dynamic> item, {required bool showDivider}) {
    final type    = item['type'] as String;
    final amount  = item['amount'] as double?;
    final color   = _typeColor(type);
    final parts   = (item['employeeName'] as String).split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'
        : parts[0][0];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['employeeName'] as String,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['summary'] as String,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (amount != null)
                    Text(
                      '\$${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type == 'timeoff'
                          ? 'Time Off'
                          : '${type[0].toUpperCase()}${type.substring(1)}',
                      style: GoogleFonts.urbanist(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }

  // ── SKELETON LOADING ──────────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    final topPad = MediaQuery.of(context).padding.top;
    return Column(
      key: const ValueKey('skeleton'),
      children: [
        // Hero skeleton
        Container(
          color: const Color(0xFF0E1E32),
          padding: EdgeInsets.fromLTRB(24, topPad + 24, 24, 0),
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
                        _bone(80, 10),
                        const SizedBox(height: 10),
                        _bone(160, 40),
                        const SizedBox(height: 10),
                        _bone(130, 13),
                        const SizedBox(height: 6),
                        _bone(110, 12),
                      ],
                    ),
                  ),
                  _bone(58, 58, radius: 20),
                ],
              ),
              const SizedBox(height: 28),
              _bone(double.infinity, 80, radius: 22),
            ],
          ),
        ),
        // Content sheet skeleton
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(120, 10),
                const SizedBox(height: 14),
                SizedBox(
                  height: 158,
                  child: Row(
                    children: [
                      Expanded(child: _bone(double.infinity, 158, radius: 20, dark: true)),
                      const SizedBox(width: 14),
                      Expanded(child: _bone(double.infinity, 158, radius: 20, dark: true)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _bone(double.infinity, 140, radius: 22, dark: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bone(double w, double h, {double radius = 10, bool dark = false}) {
    final baseColor = dark
        ? AppColors.border.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.15);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 0.8),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: baseColor.withValues(alpha: v * (dark ? 1.0 : 0.5)),
        ),
      ),
    );
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────
class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _Action(this.label, this.icon, this.color, this.onTap);
}
