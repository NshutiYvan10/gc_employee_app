import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/mock/mock_announcements.dart';

// ─────────────────────────────────────────────────
//  Department color mapping
// ─────────────────────────────────────────────────
class _DeptStyle {
  final Color background;
  final Color foreground;

  const _DeptStyle({required this.background, required this.foreground});
}

_DeptStyle _deptColor(String department) {
  final key = department.toLowerCase();
  if (key.contains('hr') || key.contains('human')) {
    return const _DeptStyle(
      background: AppColors.mistBlue,
      foreground: AppColors.primary,
    );
  }
  if (key.contains('it')) {
    return const _DeptStyle(
      background: AppColors.lavender,
      foreground: AppColors.accent,
    );
  }
  if (key.contains('treasury')) {
    return _DeptStyle(
      background: AppColors.warningLight,
      foreground: const Color(0xFFC48800),
    );
  }
  if (key.contains('facilities')) {
    return _DeptStyle(
      background: AppColors.sage,
      foreground: const Color(0xFF4E8B5A),
    );
  }
  if (key.contains('admin')) {
    return _DeptStyle(
      background: AppColors.blush,
      foreground: const Color(0xFFD46B6B),
    );
  }
  if (key.contains('minister')) {
    return _DeptStyle(
      background: AppColors.lavender,
      foreground: const Color(0xFF7C5CFC),
    );
  }
  return const _DeptStyle(
    background: AppColors.divider,
    foreground: AppColors.textSecondary,
  );
}

// ─────────────────────────────────────────────────
//  Date formatter helper
// ─────────────────────────────────────────────────
String _formatDate(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final month = int.tryParse(parts[1]) ?? 1;
  final day = int.tryParse(parts[2]) ?? 1;
  return '${months[month - 1]} $day, ${parts[0]}';
}

// ═════════════════════════════════════════════════
//  Communications Feed Screen
// ═════════════════════════════════════════════════
class CommunicationsScreen extends StatefulWidget {
  const CommunicationsScreen({super.key});

  @override
  State<CommunicationsScreen> createState() => _CommunicationsScreenState();
}

class _CommunicationsScreenState extends State<CommunicationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All';

  static const _filters = ['All', 'Announcements', 'Policies', 'Events'];

  // Maps filter label -> category value in mock data
  static const _filterCategoryMap = {
    'Announcements': 'announcement',
    'Policies': 'policy',
    'Events': 'event',
  };

  List<Map<String, dynamic>> get _filteredAnnouncements {
    var list = MockAnnouncements.announcements
        .cast<Map<String, dynamic>>();

    // Category filter
    if (_activeFilter != 'All') {
      final category = _filterCategoryMap[_activeFilter];
      list = list.where((a) => a['category'] == category).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((a) {
        final title = (a['title'] as String).toLowerCase();
        final snippet = (a['snippet'] as String).toLowerCase();
        return title.contains(q) || snippet.contains(q);
      }).toList();
    }

    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final announcements = _filteredAnnouncements;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.meshBackground),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Communications',
                  style: textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 16),

              // ── Search Bar ──────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search announcements...',
                      hintStyle: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: Icon(
                                PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                                color: AppColors.textTertiary,
                                size: 18,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Filter Chips ────────────────────────
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isActive = filter == _activeFilter;
                    return _FilterChip(
                      label: filter,
                      isActive: isActive,
                      onTap: () => setState(() => _activeFilter = filter),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // ── Announcement Feed ───────────────────
              Expanded(
                child: announcements.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 100),
                        itemCount: announcements.length,
                        itemBuilder: (context, index) {
                          final item = announcements[index];
                          return _AnnouncementCard(
                            item: item,
                            onTap: () => _openDetail(context, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.megaphone(PhosphorIconsStyle.light),
            size: 56,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No announcements found',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Map<String, dynamic> item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => _AnnouncementDetailScreen(item: item),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

// ═════════════════════════════════════════════════
//  Custom Filter Chip
// ═════════════════════════════════════════════════
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════
//  Announcement Card
// ═════════════════════════════════════════════════
class _AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dept = item['department'] as String;
    final deptStyle = _deptColor(dept);
    final isUrgent = item['priority'] == 'urgent';
    final isRead = item['isRead'] == true;
    final hasAttachment = item['hasAttachment'] == true;
    final category = item['category'] as String;

    return GlassCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Unread indicator: colored left border
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 4,
              decoration: BoxDecoration(
                color: isRead ? Colors.transparent : AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: department badge + date
                    Row(
                      children: [
                        // Department pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: deptStyle.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            dept,
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: deptStyle.foreground,
                            ),
                          ),
                        ),
                        // Urgent dot
                        if (isUrgent) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Date
                        Text(
                          _formatDate(item['date'] as String),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      item['title'] as String,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Snippet
                    Text(
                      item['snippet'] as String,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Bottom row: category pill + attachment
                    Row(
                      children: [
                        _CategoryPill(category: category),
                        if (hasAttachment) ...[
                          const SizedBox(width: 10),
                          Icon(
                            PhosphorIcons.paperclip(PhosphorIconsStyle.regular),
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item['attachmentName'] as String? ?? '',
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

// ═════════════════════════════════════════════════
//  Category Pill
// ═════════════════════════════════════════════════
class _CategoryPill extends StatelessWidget {
  final String category;

  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color fg;
    Color bg;

    switch (category) {
      case 'announcement':
        icon = PhosphorIcons.megaphone(PhosphorIconsStyle.fill);
        fg = AppColors.info;
        bg = AppColors.infoLight;
        break;
      case 'policy':
        icon = PhosphorIcons.fileText(PhosphorIconsStyle.fill);
        fg = AppColors.warning;
        bg = AppColors.warningLight;
        break;
      case 'event':
        icon = PhosphorIcons.calendarStar(PhosphorIconsStyle.fill);
        fg = AppColors.accent;
        bg = AppColors.lavender;
        break;
      default:
        icon = PhosphorIcons.info(PhosphorIconsStyle.fill);
        fg = AppColors.textSecondary;
        bg = AppColors.divider;
    }

    final label = category[0].toUpperCase() + category.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════
//  Announcement Detail Screen
// ═════════════════════════════════════════════════
class _AnnouncementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const _AnnouncementDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dept = item['department'] as String;
    final deptStyle = _deptColor(dept);
    final isUrgent = item['priority'] == 'urgent';
    final hasAttachment = item['hasAttachment'] == true;
    final category = item['category'] as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.meshBackground),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top Bar ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Urgent',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── Body ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Department + Date row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: deptStyle.background,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                dept,
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: deptStyle.foreground,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _CategoryPill(category: category),
                            const Spacer(),
                            Text(
                              _formatDate(item['date'] as String),
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          item['title'] as String,
                          style: textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Divider
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Divider(color: AppColors.divider),
                      ),
                      const SizedBox(height: 20),

                      // Body text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          item['body'] as String,
                          style: textTheme.bodyLarge?.copyWith(
                            height: 1.65,
                            color: AppColors.textPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Attachment card
                      if (hasAttachment) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GlassCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    PhosphorIcons.filePdf(PhosphorIconsStyle.fill),
                                    size: 22,
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['attachmentName'] as String,
                                        style: textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PDF Document',
                                        style: textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    PhosphorIcons.downloadSimple(
                                      PhosphorIconsStyle.bold,
                                    ),
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
