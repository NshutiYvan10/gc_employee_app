import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/gradient_button.dart';
import 'package:gc_employee_app/mock/mock_tickets.dart';
import 'package:gc_employee_app/mock/mock_devices.dart';

class ItSupportScreen extends StatefulWidget {
  const ItSupportScreen({super.key});

  @override
  State<ItSupportScreen> createState() => _ItSupportScreenState();
}

class _ItSupportScreenState extends State<ItSupportScreen> {
  int _selectedTab = 0;

  // Form state
  String? _selectedCategory;
  String? _selectedDevice;
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _hasAttachment = false;
  bool _isSubmitting = false;

  static const _categories = [
    'Password Reset',
    'Hardware',
    'Software Request',
    'Email & Collaboration',
    'Network & Connectivity',
    'Printing & Scanning',
    'Access & Accounts',
    'Other',
  ];

  static const _categoryIcons = {
    'Password Reset': PhosphorIconsBold.key,
    'Hardware': PhosphorIconsBold.laptop,
    'Software Request': PhosphorIconsBold.downloadSimple,
    'Email & Collaboration': PhosphorIconsBold.envelope,
    'Network & Connectivity': PhosphorIconsBold.wifiHigh,
    'Printing & Scanning': PhosphorIconsBold.printer,
    'Access & Accounts': PhosphorIconsBold.shieldCheck,
    'Other': PhosphorIconsBold.dotsThreeCircle,
  };

  List<Map<String, dynamic>> get _sortedTickets {
    final tickets = List<Map<String, dynamic>>.from(
      MockTickets.tickets.map((t) => Map<String, dynamic>.from(t)),
    );
    tickets.sort((a, b) =>
        (b['createdDate'] as String).compareTo(a['createdDate'] as String));
    return tickets;
  }

  List<String> get _deviceOptions {
    return MockDevices.devices.map((d) {
      return '${d['model']} (${d['assetTag']})';
    }).toList();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.meshBackground,
            ),
          ),
          // Decorative blobs
          Positioned(
            top: -60,
            left: -40,
            child: _blob(240, [
              AppColors.mistBlue.withValues(alpha: 0.7),
              AppColors.lavender.withValues(alpha: 0.3),
            ]),
          ),
          Positioned(
            top: 200,
            right: -80,
            child: _blob(200, [
              AppColors.peach.withValues(alpha: 0.5),
              AppColors.blush.withValues(alpha: 0.2),
            ]),
          ),
          Positioned(
            bottom: -40,
            left: -60,
            child: _blob(260, [
              AppColors.lavender.withValues(alpha: 0.4),
              AppColors.sage.withValues(alpha: 0.2),
            ]),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSegmentedControl(),
                const SizedBox(height: 16),
                Expanded(
                  child: _selectedTab == 0
                      ? _buildNewTicketForm()
                      : _buildMyTicketsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, List<Color> colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors, stops: const [0.0, 1.0]),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                PhosphorIconsBold.caretLeft,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IT Support',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Submit & track support requests',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              PhosphorIconsBold.headset,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Segmented Control ────────────────────────────────────────────────

  Widget _buildSegmentedControl() {
    final tabs = ['New Ticket', 'My Tickets'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final isActive = _selectedTab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.primaryGradient : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              i == 0
                                  ? PhosphorIconsBold.plusCircle
                                  : PhosphorIconsBold.ticket,
                              size: 16,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tabs[i],
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight:
                                    isActive ? FontWeight.w700 : FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  // ─── New Ticket Form ──────────────────────────────────────────────────

  Widget _buildNewTicketForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Issue Category
          _buildFieldLabel('Issue Category', PhosphorIconsBold.tag),
          _buildPickerField(
            value: _selectedCategory,
            placeholder: 'Select a category',
            icon: _selectedCategory != null
                ? _categoryIcons[_selectedCategory] ??
                    PhosphorIconsBold.caretDown
                : PhosphorIconsBold.caretDown,
            onTap: () => _showCategoryPicker(),
          ),
          const SizedBox(height: 18),

          // Affected Device
          _buildFieldLabel(
            'Affected Device',
            PhosphorIconsBold.deviceMobile,
            optional: true,
          ),
          _buildPickerField(
            value: _selectedDevice,
            placeholder: 'Select a device (optional)',
            icon: PhosphorIconsBold.caretDown,
            onTap: () => _showDevicePicker(),
          ),
          const SizedBox(height: 18),

          // Subject
          _buildFieldLabel('Subject', PhosphorIconsBold.textAa),
          _buildTextField(
            controller: _subjectController,
            hint: 'Brief summary of the issue',
            maxLines: 1,
          ),
          const SizedBox(height: 18),

          // Description
          _buildFieldLabel('Description', PhosphorIconsBold.article),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Provide details about the issue...',
            maxLines: 4,
          ),
          const SizedBox(height: 18),

          // Attachment
          _buildFieldLabel(
            'Attachment',
            PhosphorIconsBold.paperclip,
            optional: true,
          ),
          _buildAttachmentSection(),
          const SizedBox(height: 28),

          // Submit
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GradientButton(
              text: 'Submit Ticket',
              icon: PhosphorIconsBold.paperPlaneTilt,
              isLoading: _isSubmitting,
              onPressed: _canSubmit ? _submitTicket : null,
            ),
          ),
        ],
      ),
    );
  }

  bool get _canSubmit =>
      _selectedCategory != null &&
      _subjectController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      !_isSubmitting;

  Widget _buildFieldLabel(String label, IconData icon,
      {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (optional) ...[
            const SizedBox(width: 4),
            Text(
              '(optional)',
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPickerField({
    required String? value,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: value != null
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  if (value != null &&
                      _categoryIcons.containsKey(value))
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        _categoryIcons[value]!,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      value ?? placeholder,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight:
                            value != null ? FontWeight.w500 : FontWeight.w400,
                        color: value != null
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Icon(icon, size: 18, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => setState(() => _hasAttachment = !_hasAttachment),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasAttachment
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border,
                  style: _hasAttachment ? BorderStyle.solid : BorderStyle.solid,
                ),
              ),
              child: _hasAttachment
                  ? Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.mistBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            PhosphorIconsBold.image,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'screenshot_issue.png',
                                style: GoogleFonts.urbanist(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '245 KB',
                                style: GoogleFonts.urbanist(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _hasAttachment = false),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              PhosphorIconsBold.x,
                              size: 14,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.mistBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            PhosphorIconsBold.camera,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Add Screenshot',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bottom Sheet Pickers ─────────────────────────────────────────────

  void _showCategoryPicker() {
    _showPickerSheet(
      title: 'Issue Category',
      items: _categories,
      selected: _selectedCategory,
      iconBuilder: (item) =>
          _categoryIcons[item] ?? PhosphorIconsBold.dotsThreeCircle,
      onSelect: (val) => setState(() => _selectedCategory = val),
    );
  }

  void _showDevicePicker() {
    _showPickerSheet(
      title: 'Affected Device',
      items: ['None', ..._deviceOptions],
      selected: _selectedDevice,
      iconBuilder: (item) {
        if (item == 'None') return PhosphorIconsBold.prohibit;
        if (item.contains('MacBook')) return PhosphorIconsBold.laptop;
        if (item.contains('UltraSharp')) return PhosphorIconsBold.monitor;
        if (item.contains('iPhone')) return PhosphorIconsBold.deviceMobile;
        return PhosphorIconsBold.mouse;
      },
      onSelect: (val) =>
          setState(() => _selectedDevice = val == 'None' ? null : val),
    );
  }

  void _showPickerSheet({
    required String title,
    required List<String> items,
    required String? selected,
    required IconData Function(String) iconBuilder,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.7,
          builder: (_, scrollController) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        color: AppColors.border.withValues(alpha: 0.5),
                        height: 1,
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final item = items[i];
                            final isSelected = item == selected;
                            return GestureDetector(
                              onTap: () {
                                onSelect(item);
                                Navigator.pop(ctx);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                          .withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25))
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                                .withValues(alpha: 0.12)
                                            : AppColors.divider,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        iconBuilder(item),
                                        size: 18,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        PhosphorIconsBold.checkCircle,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Submit ───────────────────────────────────────────────────────────

  Future<void> _submitTicket() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final ticketId = 'INC-${28500 + Random().nextInt(500)}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.successGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      PhosphorIconsBold.checkCircle,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ticket Created!',
                    style: GoogleFonts.urbanist(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$ticketId has been submitted.\nOur team will get back to you shortly.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Done',
                    icon: PhosphorIconsBold.check,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _resetForm();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      _selectedCategory = null;
      _selectedDevice = null;
      _subjectController.clear();
      _descriptionController.clear();
      _hasAttachment = false;
    });
  }

  // ─── My Tickets List ──────────────────────────────────────────────────

  Widget _buildMyTicketsList() {
    final tickets = _sortedTickets;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: tickets.length,
      itemBuilder: (_, i) => _buildTicketCard(tickets[i]),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return GlassCard(
      onTap: () => _showTicketDetail(ticket),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Ticket ID + Priority
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticket['id'] as String,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              _buildPriorityPill(ticket['priority'] as String),
            ],
          ),
          const SizedBox(height: 10),

          // Subject
          Text(
            ticket['subject'] as String,
            style: GoogleFonts.urbanist(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Category + Status
          Row(
            children: [
              _buildCategoryPill(ticket['category'] as String),
              const SizedBox(width: 8),
              _buildStatusBadge(ticket['status'] as String),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom row: date + assigned
          Row(
            children: [
              Icon(
                PhosphorIconsBold.clockCounterClockwise,
                size: 13,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                'Updated ${_formatDate(ticket['lastUpdated'] as String)}',
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
              ),
              if (ticket['assignedTo'] != null) ...[
                const Spacer(),
                Icon(
                  PhosphorIconsBold.user,
                  size: 13,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    ticket['assignedTo'] as String,
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityPill(String priority) {
    final config = switch (priority) {
      'high' => (AppColors.error, AppColors.errorLight, 'High'),
      'medium' => (AppColors.warning, AppColors.warningLight, 'Medium'),
      _ => (AppColors.textSecondary, AppColors.divider, 'Low'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.$1.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsBold.fire, size: 11, color: config.$1),
          const SizedBox(width: 4),
          Text(
            config.$3,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.$1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        category,
        style: GoogleFonts.urbanist(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final config = switch (status) {
      'open' => (AppColors.info, AppColors.infoLight, 'Open'),
      'in_progress' => (AppColors.warning, AppColors.warningLight, 'In Progress'),
      'resolved' => (AppColors.success, AppColors.successLight, 'Resolved'),
      'closed' => (AppColors.textSecondary, AppColors.divider, 'Closed'),
      _ => (AppColors.textSecondary, AppColors.divider, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.$1.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.$1,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config.$3,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.$1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  // ─── Ticket Detail Bottom Sheet ───────────────────────────────────────

  void _showTicketDetail(Map<String, dynamic> ticket) {
    final messages =
        List<Map<String, dynamic>>.from(ticket['messages'] as List);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary
                                  .withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ticket['id'] as String,
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(ticket['status'] as String),
                          const Spacer(),
                          _buildPriorityPill(ticket['priority'] as String),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        ticket['subject'] as String,
                        style: GoogleFonts.urbanist(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Info chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryPill(ticket['category'] as String),
                          if (ticket['assignedTo'] != null)
                            _buildInfoChip(
                              PhosphorIconsBold.user,
                              ticket['assignedTo'] as String,
                            ),
                          _buildInfoChip(
                            PhosphorIconsBold.calendar,
                            'Created ${_formatDate(ticket['createdDate'] as String)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket['description'] as String,
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Message thread
                      Row(
                        children: [
                          Icon(PhosphorIconsBold.chatCircleDots,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Message Thread',
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.mistBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${messages.length}',
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ...messages.map((msg) => _buildMessageBubble(msg)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 5),
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
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isTechnician = msg['role'] == 'technician';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: isTechnician
                  ? AppColors.primaryGradient
                  : AppColors.warmGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isTechnician
                  ? PhosphorIconsBold.wrench
                  : PhosphorIconsBold.user,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      msg['author'] as String,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isTechnician)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'IT',
                          style: GoogleFonts.urbanist(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatMessageDate(msg['date'] as String),
                  style: GoogleFonts.urbanist(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTechnician
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTechnician
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    msg['text'] as String,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                      height: 1.5,
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

  String _formatMessageDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month]} ${date.day} at $hour:$min $amPm';
  }
}
