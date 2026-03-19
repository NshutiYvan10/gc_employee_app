import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/gradient_button.dart';
import 'package:gc_employee_app/mock/mock_users.dart';
import 'package:gc_employee_app/mock/mock_leave.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  bool _isEditingContact = false;
  late TextEditingController _phoneController;
  late TextEditingController _officeController;

  final _user = MockUser.currentUser;
  final _directReports = MockUser.directReports;
  final _leave = MockLeave.balances;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: _user['phone'] as String);
    _officeController =
        TextEditingController(text: _user['officeLocation'] as String);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _officeController.dispose();
    super.dispose();
  }

  String _formatHireDate(String iso) {
    final date = DateTime.parse(iso);
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isManager = _user['role'] == 'manager';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient header
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
          ),
          // Subtle mesh overlay
          Container(
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.0),
                  AppColors.background,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          PhosphorIconsBold.caretLeft,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'My Profile',
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildProfileHero(),
                        const SizedBox(height: 20),
                        _buildContactInformation(),
                        const SizedBox(height: 8),
                        _buildEmploymentDetails(),
                        const SizedBox(height: 8),
                        _buildLeaveBalances(),
                        if (isManager) ...[
                          const SizedBox(height: 8),
                          _buildTeamSection(),
                        ],
                        const SizedBox(height: 8),
                        _buildQuickLinks(),
                        const SizedBox(height: 8),
                        _buildCertifications(),
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

  // ── Profile Hero Header ──────────────────────────────────────────────

  Widget _buildProfileHero() {
    return Column(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
            child: Text(
              _user['avatarInitials'] as String,
              style: GoogleFonts.urbanist(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Name
        Text(
          _user['legalName'] as String,
          style: GoogleFonts.urbanist(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        // Job title + department
        Text(
          '${_user['jobTitle']}  ·  ${_user['department']}',
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        // Employee ID pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.mistBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _user['employeeId'] as String,
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  // ── Contact Information ──────────────────────────────────────────────

  Widget _buildContactInformation() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(PhosphorIconsBold.addressBook,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Contact Information',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_isEditingContact) {
                      // Cancel editing: reset values
                      _phoneController.text = _user['phone'] as String;
                      _officeController.text =
                          _user['officeLocation'] as String;
                    }
                    _isEditingContact = !_isEditingContact;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isEditingContact
                        ? AppColors.errorLight
                        : AppColors.mistBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _isEditingContact ? 'Cancel' : 'Edit',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isEditingContact
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Email (always read-only)
          _buildContactRow(
            icon: PhosphorIconsRegular.envelopeSimple,
            label: 'Email',
            value: _user['email'] as String,
          ),
          const SizedBox(height: 14),
          // Phone
          _isEditingContact
              ? _buildEditableRow(
                  icon: PhosphorIconsRegular.phone,
                  label: 'Phone',
                  controller: _phoneController,
                )
              : _buildContactRow(
                  icon: PhosphorIconsRegular.phone,
                  label: 'Phone',
                  value: _user['phone'] as String,
                ),
          const SizedBox(height: 14),
          // Office Location
          _isEditingContact
              ? _buildEditableRow(
                  icon: PhosphorIconsRegular.mapPin,
                  label: 'Office',
                  controller: _officeController,
                )
              : _buildContactRow(
                  icon: PhosphorIconsRegular.mapPin,
                  label: 'Office',
                  value: _user['officeLocation'] as String,
                ),
          // Save button when editing
          if (_isEditingContact) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    text: 'Save Changes',
                    icon: PhosphorIconsBold.checkCircle,
                    height: 44,
                    fontSize: 14,
                    onPressed: () {
                      setState(() {
                        _isEditingContact = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Contact information updated',
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(20),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.mistBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              TextField(
                controller: controller,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: AppColors.lavender.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Employment Details ───────────────────────────────────────────────

  Widget _buildEmploymentDetails() {
    final details = [
      {
        'icon': PhosphorIconsRegular.calendar,
        'label': 'Hire Date',
        'value': _formatHireDate(_user['hireDate'] as String),
      },
      {
        'icon': PhosphorIconsRegular.userCircle,
        'label': 'Manager',
        'value': _user['manager'] as String,
      },
      {
        'icon': PhosphorIconsRegular.briefcase,
        'label': 'Employment Type',
        'value': _user['employmentType'] as String,
      },
      {
        'icon': PhosphorIconsRegular.clock,
        'label': 'Work Schedule',
        'value': _user['workSchedule'] as String,
      },
      {
        'icon': PhosphorIconsRegular.buildings,
        'label': 'Cost Center',
        'value': _user['costCenter'] as String,
      },
      {
        'icon': PhosphorIconsRegular.chartBar,
        'label': 'Pay Grade',
        'value': _user['payGrade'] as String,
      },
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsBold.identificationBadge,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Employment Details',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...details.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(d['icon'] as IconData,
                        size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 110,
                      child: Text(
                        d['label'] as String,
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        d['value'] as String,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.info,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Contact HR to change legal or employment details',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
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

  // ── Leave Balances ───────────────────────────────────────────────────

  Widget _buildLeaveBalances() {
    final vacation = _leave['vacation']!;
    final sick = _leave['sick']!;
    final personal = _leave['personal']!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(PhosphorIconsBold.calendarCheck,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Leave Balances',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildLeaveCard(
                  label: 'Vacation',
                  available: vacation['available'] as int,
                  total: vacation['totalAnnual'] as int,
                  color: AppColors.primary,
                  bgColor: AppColors.mistBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLeaveCard(
                  label: 'Sick',
                  available: sick['available'] as int,
                  total: sick['totalAnnual'] as int,
                  color: AppColors.warning,
                  bgColor: AppColors.warningLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLeaveCard(
                  label: 'Personal',
                  available: personal['available'] as int,
                  total: personal['totalAnnual'] as int,
                  color: AppColors.accent,
                  bgColor: AppColors.lavender,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard({
    required String label,
    required int available,
    required int total,
    required Color color,
    required Color bgColor,
  }) {
    final progress = total > 0 ? available / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                progress: progress,
                color: color,
                trackColor: color.withValues(alpha: 0.15),
                strokeWidth: 4,
              ),
              child: Center(
                child: Text(
                  '$available',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$available/$total days',
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

  // ── Team / Direct Reports ────────────────────────────────────────────

  Widget _buildTeamSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsBold.usersThree,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Direct Reports (${_directReports.length})',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._directReports.asMap().entries.map((entry) {
            final index = entry.key;
            final report = entry.value;
            final colors = [
              AppColors.primary,
              AppColors.accent,
              AppColors.info,
            ];
            final bgColors = [
              AppColors.mistBlue,
              AppColors.lavender,
              AppColors.infoLight,
            ];

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < _directReports.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Viewing ${report['name']}\'s profile',
                        style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(20),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColors[index % bgColors.length]
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors[index % colors.length]
                              .withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Text(
                            report['avatarInitials'] as String,
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors[index % colors.length],
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
                              report['name'] as String,
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              report['jobTitle'] as String,
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        PhosphorIconsRegular.caretRight,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Quick Links ──────────────────────────────────────────────────────

  Widget _buildQuickLinks() {
    final links = [
      {
        'icon': PhosphorIconsBold.currencyDollar,
        'label': 'Pay Statements',
        'color': AppColors.success,
        'bg': AppColors.successLight,
      },
      {
        'icon': PhosphorIconsBold.fileText,
        'label': 'Documents',
        'color': AppColors.primary,
        'bg': AppColors.mistBlue,
      },
      {
        'icon': PhosphorIconsBold.firstAid,
        'label': 'Emergency Contacts',
        'color': AppColors.error,
        'bg': AppColors.errorLight,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(PhosphorIconsBold.link,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Quick Links',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: links.map((link) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening ${link['label']}...',
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: link['color'] as Color,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(20),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: link['bg'] as Color,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              (link['color'] as Color).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            link['icon'] as IconData,
                            size: 18,
                            color: link['color'] as Color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            link['label'] as String,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: link['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Certifications ───────────────────────────────────────────────────

  Widget _buildCertifications() {
    final certs = (_user['certifications'] as List).cast<String>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsBold.certificate,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Certifications',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...certs.map((cert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.sage,
                        AppColors.sage.withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          PhosphorIconsBold.sealCheck,
                          size: 18,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cert,
                          style: GoogleFonts.urbanist(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Circular Progress Painter ────────────────────────────────────────────

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
