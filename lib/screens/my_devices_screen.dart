import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/status_badge.dart';
import 'package:gc_employee_app/mock/mock_devices.dart';

class MyDevicesScreen extends StatefulWidget {
  const MyDevicesScreen({super.key});

  @override
  State<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends State<MyDevicesScreen> {
  final Set<String> _expandedDevices = {};
  static final DateTime _today = DateTime(2026, 3, 19);

  List<Map<String, dynamic>> get _devices =>
      MockDevices.devices.cast<Map<String, dynamic>>();

  int get _eligibleCount =>
      _devices.where((d) => d['status'] == 'eligible').length;
  int get _upcomingCount =>
      _devices.where((d) => d['status'] == 'upcoming').length;
  int get _notEligibleCount =>
      _devices.where((d) => d['status'] == 'not_eligible').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.meshBackground),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSummaryStats(),
                    const SizedBox(height: 8),
                    ..._devices.map(_buildDeviceCard),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              color: AppColors.textPrimary,
              size: 22,
            ),
            splashRadius: 20,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Devices',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_devices.length} assigned devices',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatChip(_eligibleCount, 'eligible for refresh',
              AppColors.success),
          const SizedBox(width: 12),
          _buildStatChip(_upcomingCount, 'upcoming', AppColors.warning),
          const SizedBox(width: 12),
          _buildStatChip(
              _notEligibleCount, 'not eligible', AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildStatChip(int count, String label, Color dotColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$count $label',
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final String id = device['id'] as String;
    final String type = device['type'] as String;
    final String make = device['make'] as String;
    final String model = device['model'] as String;
    final int year = device['year'] as int;
    final String assetTag = device['assetTag'] as String;
    final String status = device['status'] as String;
    final String assignmentDateStr = device['assignmentDate'] as String;
    final String refreshEligibleDateStr =
        device['refreshEligibleDate'] as String;
    final int refreshCycleMonths = device['refreshCycleMonths'] as int;
    final String warrantyExpirationStr =
        device['warrantyExpiration'] as String;
    final String? notes = device['notes'] as String?;
    final Map<String, dynamic> specs =
        (device['specs'] as Map).cast<String, dynamic>();
    final String serialNumber = device['serialNumber'] as String;

    final DateTime assignmentDate = DateTime.parse(assignmentDateStr);
    final DateTime refreshEligibleDate =
        DateTime.parse(refreshEligibleDateStr);
    final DateTime warrantyExpiration = DateTime.parse(warrantyExpirationStr);
    final bool isWarrantyExpired = warrantyExpiration.isBefore(_today);
    final bool isExpanded = _expandedDevices.contains(id);

    final Color statusColor = _statusColor(status);
    final double progress = _calculateProgress(
        assignmentDate, refreshEligibleDate, refreshCycleMonths);
    final int monthsSinceAssignment = _monthsBetween(assignmentDate, _today);
    final int monthsUntilRefresh =
        _monthsBetween(_today, refreshEligibleDate).clamp(0, 999);

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored left border accent via IntrinsicHeight + Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: icon + make/model + year badge + warranty warning
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _deviceIcon(type),
                                color: statusColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$make $model',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    assetTag,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textTertiary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$year',
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (isWarrantyExpired) ...[
                              const SizedBox(width: 6),
                              Tooltip(
                                message: 'Warranty expired',
                                child: Icon(
                                  PhosphorIcons.shieldWarning(
                                      PhosphorIconsStyle.fill),
                                  color: AppColors.error.withValues(alpha: 0.7),
                                  size: 18,
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Assignment date
                        Text(
                          'Assigned ${_formatDate(assignmentDate)}',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Refresh status section
                        _buildRefreshStatusSection(
                          status: status,
                          statusColor: statusColor,
                          progress: progress,
                          monthsSinceAssignment: monthsSinceAssignment,
                          refreshCycleMonths: refreshCycleMonths,
                          monthsUntilRefresh: monthsUntilRefresh,
                          refreshEligibleDate: refreshEligibleDate,
                        ),

                        const SizedBox(height: 12),

                        // Expand / collapse specs
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedDevices.remove(id);
                              } else {
                                _expandedDevices.add(id);
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                isExpanded ? 'Hide details' : 'View details',
                                style: GoogleFonts.urbanist(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: Icon(
                                  PhosphorIcons.caretDown(
                                      PhosphorIconsStyle.bold),
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expandable specs
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: _buildExpandedSpecs(
                            specs: specs,
                            serialNumber: serialNumber,
                            warrantyExpiration: warrantyExpiration,
                            isWarrantyExpired: isWarrantyExpired,
                            notes: notes,
                          ),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                          sizeCurve: Curves.easeInOut,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshStatusSection({
    required String status,
    required Color statusColor,
    required double progress,
    required int monthsSinceAssignment,
    required int refreshCycleMonths,
    required int monthsUntilRefresh,
    required DateTime refreshEligibleDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(status: status),
              const Spacer(),
              if (status == 'eligible')
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ready for refresh!',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                )
              else if (status == 'upcoming')
                Text(
                  '$monthsUntilRefresh months until refresh',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                )
              else
                Text(
                  'Eligible: ${_formatDateShort(refreshEligibleDate)}',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          _buildProgressBar(
            progress: progress,
            color: statusColor,
          ),
          const SizedBox(height: 6),

          // Months label
          Text(
            '${monthsSinceAssignment.clamp(0, refreshCycleMonths)} of $refreshCycleMonths months',
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required double progress,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              width: maxWidth * progress,
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.7),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedSpecs({
    required Map<String, dynamic> specs,
    required String serialNumber,
    required DateTime warrantyExpiration,
    required bool isWarrantyExpired,
    required String? notes,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.divider,
          ),
          const SizedBox(height: 12),
          Text(
            'Specifications',
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...specs.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      _formatSpecKey(entry.key),
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${entry.value}',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.divider,
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Serial', serialNumber),
          const SizedBox(height: 6),
          _buildDetailRow(
            'Warranty',
            _formatDate(warrantyExpiration),
            valueColor: isWarrantyExpired ? AppColors.error : null,
            suffix: isWarrantyExpired
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Expired',
                          style: GoogleFonts.urbanist(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIcons.info(PhosphorIconsStyle.fill),
                    color: AppColors.info,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
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

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, Widget? suffix}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        if (suffix != null) suffix,
      ],
    );
  }

  // --- Helpers ---

  IconData _deviceIcon(String type) {
    switch (type) {
      case 'Laptop':
        return PhosphorIcons.laptop(PhosphorIconsStyle.duotone);
      case 'Monitor':
        return PhosphorIcons.monitor(PhosphorIconsStyle.duotone);
      case 'Mobile Phone':
        return PhosphorIcons.deviceMobile(PhosphorIconsStyle.duotone);
      case 'Peripheral':
        return PhosphorIcons.mouse(PhosphorIconsStyle.duotone);
      default:
        return PhosphorIcons.devices(PhosphorIconsStyle.duotone);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'eligible':
        return AppColors.success;
      case 'upcoming':
        return AppColors.warning;
      case 'not_eligible':
      default:
        return AppColors.textTertiary;
    }
  }

  double _calculateProgress(
      DateTime assignmentDate, DateTime refreshEligibleDate, int cycleMo) {
    final totalDays = refreshEligibleDate.difference(assignmentDate).inDays;
    if (totalDays <= 0) return 1.0;
    final elapsed = _today.difference(assignmentDate).inDays;
    return (elapsed / totalDays).clamp(0.0, 1.0);
  }

  int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSpecKey(String key) {
    // camelCase to Title Case
    final result = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    return '${result[0].toUpperCase()}${result.substring(1)}';
  }
}
