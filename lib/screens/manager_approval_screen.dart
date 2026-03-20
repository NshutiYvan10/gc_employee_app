import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/gradient_button.dart';
import 'package:gc_employee_app/mock/mock_approvals.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Manager Approval Queue Screen
// ─────────────────────────────────────────────────────────────────────────────
class ManagerApprovalScreen extends StatefulWidget {
  const ManagerApprovalScreen({super.key});

  @override
  State<ManagerApprovalScreen> createState() => _ManagerApprovalScreenState();
}

class _ManagerApprovalScreenState extends State<ManagerApprovalScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  String _activeFilter = 'All';
  bool _batchMode = false;
  final Set<String> _selected = {};
  late List<Map<String, dynamic>> _pending;
  late List<Map<String, dynamic>> _actioned;

  static const _filters = ['All', 'Travel', 'Expenses', 'Time Off'];

  @override
  void initState() {
    super.initState();
    _pending = List<Map<String, dynamic>>.from(
      MockApprovals.pendingApprovals,
    );
    _actioned = List<Map<String, dynamic>>.from(
      MockApprovals.recentlyActioned,
    );
  }

  // ── Filter logic ───────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 'All') return _pending;
    final key = _typeKeyFor(_activeFilter);
    return _pending.where((a) => a['type'] == key).toList();
  }

  String _typeKeyFor(String label) {
    switch (label) {
      case 'Travel':
        return 'travel';
      case 'Expenses':
        return 'expense';
      case 'Time Off':
        return 'timeoff';
      default:
        return '';
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _approveItem(String id) {
    final item = _pending.firstWhere((a) => a['id'] == id);
    setState(() {
      _pending.removeWhere((a) => a['id'] == id);
      _actioned.insert(0, {
        ...item,
        'status': 'approved',
        'actionDate': DateTime.now().toIso8601String(),
      });
      _selected.remove(id);
    });
    _showSnack('Approved', AppColors.success);
  }

  void _rejectItem(String id) {
    final item = _pending.firstWhere((a) => a['id'] == id);
    setState(() {
      _pending.removeWhere((a) => a['id'] == id);
      _actioned.insert(0, {
        ...item,
        'status': 'rejected',
        'actionDate': DateTime.now().toIso8601String(),
      });
      _selected.remove(id);
    });
    _showSnack('Rejected', AppColors.error);
  }

  void _approveSelected() {
    final ids = Set<String>.from(_selected);
    for (final id in ids) {
      _approveItem(id);
    }
    setState(() {
      _batchMode = false;
      _selected.clear();
    });
  }

  void _rejectSelected() {
    final ids = Set<String>.from(_selected);
    for (final id in ids) {
      _rejectItem(id);
    }
    setState(() {
      _batchMode = false;
      _selected.clear();
    });
  }

  void _showSnack(String label, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label,
            style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient gradient blobs
          _ambientBlob(
            top: -60, right: -60,
            color: AppColors.accentLight.withValues(alpha: 0.14),
          ),
          _ambientBlob(
            bottom: 200, left: -80,
            color: AppColors.primaryLight.withValues(alpha: 0.1),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildStatsRow(),
                const SizedBox(height: 8),
                _buildFilterChips(),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty && _actioned.isEmpty
                      ? _buildEmpty()
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 120),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            if (filtered.isNotEmpty) ...[
                              _buildSectionLabel(
                                  'Pending Review (${filtered.length})'),
                              ...filtered.map(_buildApprovalCard),
                            ],
                            if (_actioned.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildSectionLabel('Recently Actioned'),
                              ..._actioned.take(5).map(_buildActionedCard),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Floating batch-action bar
          if (_batchMode && _selected.isNotEmpty)
            _buildBatchBar(),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: Icon(
                PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approval Queue',
                  style: GoogleFonts.urbanist(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  '${_pending.length} pending • ${_actioned.length} recently actioned',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Batch mode toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _batchMode = !_batchMode;
                if (!_batchMode) _selected.clear();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient:
                    _batchMode ? AppColors.primaryGradient : null,
                color: _batchMode ? null : AppColors.mistBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _batchMode ? 'Cancel' : 'Select',
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      _batchMode ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row (mini KPI cards) ─────────────────────────────────────────────
  Widget _buildStatsRow() {
    final travelCount =
        _pending.where((a) => a['type'] == 'travel').length;
    final expenseCount =
        _pending.where((a) => a['type'] == 'expense').length;
    final leaveCount =
        _pending.where((a) => a['type'] == 'timeoff').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _statPill(
            travelCount.toString(),
            'Travel',
            AppColors.primary,
            PhosphorIcons.airplaneTilt(PhosphorIconsStyle.fill),
          ),
          const SizedBox(width: 10),
          _statPill(
            expenseCount.toString(),
            'Expenses',
            AppColors.warning,
            PhosphorIcons.receipt(PhosphorIconsStyle.fill),
          ),
          const SizedBox(width: 10),
          _statPill(
            leaveCount.toString(),
            'Leave',
            AppColors.success,
            PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
          ),
        ],
      ),
    );
  }

  Widget _statPill(
      String count, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: color.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: GoogleFonts.urbanist(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final isActive = f == _activeFilter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.primaryGradient : null,
                color: isActive ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(
                        color: AppColors.border, width: 1),
              ),
              child: Text(
                f,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        label,
        style: GoogleFonts.urbanist(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ── Pending approval card ──────────────────────────────────────────────────
  Widget _buildApprovalCard(Map<String, dynamic> item) {
    final id = item['id'] as String;
    final type = item['type'] as String;
    final name = item['employeeName'] as String;
    final summary = item['summary'] as String;
    final amount = item['amount'] as double?;
    final submitted = item['submittedDate'] as String;
    final urgency = item['urgency'] as String? ?? 'normal';
    final isHighUrgency = urgency == 'high';
    final isSelected = _selected.contains(id);

    final typeColor = _typeColor(type);
    final typeIcon = _typeIcon(type);
    final typeLabel = _typeLabel(type);
    final initials = _initials(name);
    final avatarColor = _avatarColor(name);

    return GestureDetector(
      onTap: _batchMode
          ? () {
              setState(() {
                if (isSelected) {
                  _selected.remove(id);
                } else {
                  _selected.add(id);
                }
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.35)
                : isHighUrgency
                    ? AppColors.warning.withValues(alpha: 0.4)
                    : AppColors.glassBorder,
            width: isSelected || isHighUrgency ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card content ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: avatar + name + type badge + checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: avatarColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: avatarColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Name + date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Submitted ${_formatDate(submitted)}',
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Urgency indicator or batch checkbox
                      if (_batchMode)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white)
                              : null,
                        )
                      else if (isHighUrgency)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Urgent',
                                style: GoogleFonts.urbanist(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Type + amount row
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: typeColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(typeIcon,
                                size: 13, color: typeColor),
                            const SizedBox(width: 5),
                            Text(
                              typeLabel,
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (amount != null)
                        Text(
                          '\$${_formatAmount(amount)}',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Request ID
                  Text(
                    item['id'] as String,
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Summary
                  Text(
                    summary,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Action buttons (not in batch mode) ───────────────────
            if (!_batchMode)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: AppColors.divider, width: 1)),
                ),
                child: Row(
                  children: [
                    // Reject
                    Expanded(
                      child: _actionButton(
                        label: 'Reject',
                        icon: PhosphorIcons.x(
                            PhosphorIconsStyle.bold),
                        color: AppColors.error,
                        bgColor: AppColors.errorLight,
                        onTap: () => _showConfirmDialog(
                          title: 'Reject Request',
                          message:
                              'Reject "${item['id']}" from $name?',
                          confirmLabel: 'Reject',
                          confirmColor: AppColors.error,
                          onConfirm: () => _rejectItem(id),
                        ),
                      ),
                    ),
                    // Divider
                    Container(
                        width: 1,
                        height: 44,
                        color: AppColors.divider),
                    // Approve
                    Expanded(
                      child: _actionButton(
                        label: 'Approve',
                        icon: PhosphorIcons.check(
                            PhosphorIconsStyle.bold),
                        color: AppColors.success,
                        bgColor: AppColors.successLight,
                        onTap: () => _approveItem(id),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recently actioned card ─────────────────────────────────────────────────
  Widget _buildActionedCard(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final name = item['employeeName'] as String;
    final summary = item['summary'] as String;
    final status = item['status'] as String;
    final amount = item['amount'] as double?;
    final isApproved = status == 'approved';
    final statusColor =
        isApproved ? AppColors.success : AppColors.error;
    final initials = _initials(name);
    final avatarColor = _avatarColor(name);
    final typeIcon = _typeIcon(type);
    final typeColor = _typeColor(type);

    return GlassCard(
      backgroundColor: statusColor.withValues(alpha: 0.04),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with status overlay
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      avatarColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: avatarColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.surface, width: 1.5),
                  ),
                  child: Icon(
                    isApproved
                        ? Icons.check_rounded
                        : Icons.close_rounded,
                    size: 9,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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
                        name,
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (amount != null)
                      Text(
                        '\$${_formatAmount(amount)}',
                        style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(typeIcon,
                        size: 12,
                        color: typeColor.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      _typeLabel(type),
                      style: GoogleFonts.urbanist(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            typeColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            statusColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: Text(
                        isApproved ? 'Approved' : 'Rejected',
                        style: GoogleFonts.urbanist(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Batch action bar ───────────────────────────────────────────────────────
  Widget _buildBatchBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              border: Border(
                  top: BorderSide(
                      color: AppColors.border, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selected.length} selected',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _rejectSelected,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius:
                                BorderRadius.circular(25),
                            border: Border.all(
                                color: AppColors.error
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                  PhosphorIcons.x(
                                      PhosphorIconsStyle.bold),
                                  size: 16,
                                  color: AppColors.error),
                              const SizedBox(width: 8),
                              Text(
                                'Reject All',
                                style: GoogleFonts.urbanist(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        text: 'Approve All',
                        icon: PhosphorIcons.check(
                            PhosphorIconsStyle.bold),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.success,
                            Color(0xFF5AC8FA)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onPressed: _approveSelected,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'All caught up!',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending approvals at this time.',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm dialog ─────────────────────────────────────────────────────────
  Future<void> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: GoogleFonts.urbanist(
                fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text(message,
            style: GoogleFonts.urbanist(
                fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.urbanist(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel,
                style: GoogleFonts.urbanist(
                    color: confirmColor,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }

  // ── Ambient blob helper ────────────────────────────────────────────────────
  Widget _ambientBlob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color _typeColor(String type) {
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

  IconData _typeIcon(String type) {
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

  String _typeLabel(String type) {
    switch (type) {
      case 'travel':
        return 'Travel';
      case 'expense':
        return 'Expense';
      case 'timeoff':
        return 'Time Off';
      default:
        return type;
    }
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  Color _avatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatAmount(double v) {
    if (v == v.roundToDouble()) {
      return v
          .toStringAsFixed(0)
          .replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    }
    final parts = v.toStringAsFixed(2).split('.');
    return '${parts[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}' '.${parts[1]}';
  }
}
