import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/gradient_button.dart';
import 'package:gc_employee_app/widgets/status_badge.dart';
import 'package:gc_employee_app/widgets/gradient_background.dart';
import 'package:gc_employee_app/mock/mock_expenses.dart';
import 'package:gc_employee_app/mock/mock_users.dart';

// ---------------------------------------------------------------------------
// Data model for a single expense line item
// ---------------------------------------------------------------------------
class _LineItem {
  DateTime? date;
  String? categoryId;
  String? categoryName;
  String vendor = '';
  double amount = 0.0;
  String? paymentType;
  String purpose = '';
  bool hasReceipt = false;

  _LineItem();
}

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------
class ExpenseSubmissionScreen extends StatefulWidget {
  const ExpenseSubmissionScreen({super.key});

  @override
  State<ExpenseSubmissionScreen> createState() =>
      _ExpenseSubmissionScreenState();
}

class _ExpenseSubmissionScreenState extends State<ExpenseSubmissionScreen>
    with SingleTickerProviderStateMixin {
  // View toggle: 0 = New Report, 1 = My Reports
  int _activeTab = 0;

  // ---------- New Report state ----------
  late TextEditingController _reportNameController;
  final List<_LineItem> _lineItems = [_LineItem()];
  bool _isSubmitting = false;

  // ---------- My Reports state ----------
  final Set<String> _expandedReportIds = {};

  @override
  void initState() {
    super.initState();
    final now = DateFormat('MMM d, yyyy').format(DateTime.now());
    _reportNameController =
        TextEditingController(text: 'Expense Report - $now');
  }

  @override
  void dispose() {
    _reportNameController.dispose();
    super.dispose();
  }

  double get _runningTotal =>
      _lineItems.fold(0.0, (sum, item) => sum + item.amount);

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 8),
            _buildSegmentedControl(),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _activeTab == 0
                    ? _buildNewReportView()
                    : _buildMyReportsView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------------------
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
              child: const Icon(PhosphorIconsRegular.caretLeft,
                  size: 20, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Expenses',
              style: GoogleFonts.urbanist(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Segmented control
  // ---------------------------------------------------------------------------
  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          _segmentPill('New Report', 0),
          _segmentPill('My Reports', 1),
        ],
      ),
    );
  }

  Widget _segmentPill(String label, int index) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  //  VIEW 1 — New Report
  // ===========================================================================
  Widget _buildNewReportView() {
    return ListView(
      key: const ValueKey('new_report'),
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        _buildReportHeader(),
        const SizedBox(height: 4),
        ..._lineItems
            .asMap()
            .entries
            .map((e) => _buildLineItemCard(e.key, e.value)),
        _buildAddLineItemButton(),
        const SizedBox(height: 8),
        _buildRunningTotal(),
        _buildPolicyTip(),
        const SizedBox(height: 16),
        _buildSubmitButton(),
        const SizedBox(height: 24),
      ],
    );
  }

  // --------------- Report Header ---------------
  Widget _buildReportHeader() {
    final costCenter =
        MockUser.currentUser['costCenter'] as String? ?? 'N/A';
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report Details',
              style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          _glassTextField(
            controller: _reportNameController,
            label: 'Report Name',
            icon: PhosphorIconsRegular.notepad,
          ),
          const SizedBox(height: 12),
          _readOnlyField(
            label: 'Cost Center',
            value: costCenter,
            icon: PhosphorIconsRegular.buildings,
          ),
        ],
      ),
    );
  }

  // --------------- Single Line Item Card ---------------
  Widget _buildLineItemCard(int index, _LineItem item) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: GoogleFonts.urbanist(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text('Line Item ${index + 1}',
                  style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const Spacer(),
              if (_lineItems.length > 1)
                GestureDetector(
                  onTap: () => setState(() => _lineItems.removeAt(index)),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(PhosphorIconsRegular.trash,
                        size: 16, color: AppColors.error),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Date
          _glassPickerField(
            label: 'Date',
            value: item.date != null
                ? DateFormat('MMM d, yyyy').format(item.date!)
                : null,
            placeholder: 'Select date',
            icon: PhosphorIconsRegular.calendar,
            onTap: () => _pickDate(item),
          ),
          const SizedBox(height: 12),

          // Category
          _glassPickerField(
            label: 'Category',
            value: item.categoryName,
            placeholder: 'Select category',
            icon: PhosphorIconsRegular.tag,
            onTap: () => _showCategoryPicker(item),
          ),
          const SizedBox(height: 12),

          // Vendor
          _glassTextField(
            label: 'Vendor',
            icon: PhosphorIconsRegular.storefront,
            initialValue: item.vendor,
            onChanged: (v) => item.vendor = v,
          ),
          const SizedBox(height: 12),

          // Amount
          _glassTextField(
            label: 'Amount',
            icon: PhosphorIconsRegular.currencyDollar,
            prefix: '\$',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            onChanged: (v) {
              item.amount = double.tryParse(v) ?? 0.0;
              setState(() {}); // update running total
            },
          ),
          const SizedBox(height: 12),

          // Payment Type
          _glassPickerField(
            label: 'Payment Type',
            value: item.paymentType,
            placeholder: 'Select payment type',
            icon: PhosphorIconsRegular.creditCard,
            onTap: () => _showPaymentTypePicker(item),
          ),
          const SizedBox(height: 12),

          // Business Purpose
          _glassTextField(
            label: 'Business Purpose',
            icon: PhosphorIconsRegular.chatText,
            initialValue: item.purpose,
            onChanged: (v) => item.purpose = v,
            maxLines: 2,
          ),
          const SizedBox(height: 14),

          // Receipt
          _buildReceiptButton(item),
        ],
      ),
    );
  }

  // --------------- Receipt attachment ---------------
  Widget _buildReceiptButton(_LineItem item) {
    if (item.hasReceipt) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(PhosphorIconsFill.image,
                  size: 20, color: AppColors.success),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('receipt_001.jpg',
                      style: GoogleFonts.urbanist(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text('Attached',
                      style: GoogleFonts.urbanist(
                          fontSize: 11, color: AppColors.success)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => item.hasReceipt = false),
              child: const Icon(PhosphorIconsRegular.x,
                  size: 16, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => item.hasReceipt = true),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.mistBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(PhosphorIconsRegular.camera,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Add Receipt',
                style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  // --------------- Add line item button ---------------
  Widget _buildAddLineItemButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: () => setState(() => _lineItems.add(_LineItem())),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(PhosphorIconsRegular.plus,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Add Line Item',
                  style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }

  // --------------- Running total ---------------
  Widget _buildRunningTotal() {
    return GlassCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.07),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(PhosphorIconsBold.receipt,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Text('Total',
              style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            '\$${_runningTotal.toStringAsFixed(2)}',
            style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // --------------- Policy tip ---------------
  Widget _buildPolicyTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(PhosphorIconsFill.info,
                size: 16, color: AppColors.info),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Meals over \$50 require receipt',
                  style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.info)),
            ),
          ],
        ),
      ),
    );
  }

  // --------------- Submit button ---------------
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GradientButton(
        text: 'Submit for Approval',
        icon: PhosphorIconsBold.paperPlaneTilt,
        isLoading: _isSubmitting,
        onPressed: _submit,
        width: double.infinity,
      ),
    );
  }

  // --------------- Submit flow ---------------
  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final id = 'EXP-2026-${(100 + DateTime.now().millisecond % 900)}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuccessSheet(reportId: id),
    );
  }

  // ===========================================================================
  //  VIEW 2 — My Reports
  // ===========================================================================
  Widget _buildMyReportsView() {
    final reports = MockExpenses.reports;
    return ListView.builder(
      key: const ValueKey('my_reports'),
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final r = reports[index];
        final id = r['id'] as String;
        final isExpanded = _expandedReportIds.contains(id);
        final lineItems = (r['lineItems'] as List?) ?? [];
        final total = (r['total'] as num?)?.toDouble() ?? 0.0;
        final status = r['status'] as String? ?? 'draft';
        final submitted = r['submittedDate'] as String?;

        return GlassCard(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedReportIds.remove(id);
              } else {
                _expandedReportIds.add(id);
              }
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['name'] as String? ?? '',
                            style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        if (submitted != null)
                          Text(
                            'Submitted ${_formatDateString(submitted)}',
                            style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: AppColors.textTertiary),
                          ),
                      ],
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),

              // Meta row
              Row(
                children: [
                  _metaChip(PhosphorIconsRegular.receipt,
                      '\$${total.toStringAsFixed(2)}'),
                  const SizedBox(width: 12),
                  _metaChip(PhosphorIconsRegular.listDashes,
                      '${lineItems.length} items'),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(PhosphorIconsRegular.caretDown,
                        size: 18, color: AppColors.textTertiary),
                  ),
                ],
              ),

              // Expanded line items
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedLineItems(lineItems),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandedLineItems(List<dynamic> lineItems) {
    if (lineItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Text('No line items yet.',
            style: GoogleFonts.urbanist(
                fontSize: 13, color: AppColors.textTertiary)),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          height: 1,
          color: AppColors.divider,
        ),
        const SizedBox(height: 8),
        ...lineItems.map((li) {
          final item = li as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _categoryIcon(item['category'] as String? ?? ''),
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['vendor'] as String? ?? '',
                          style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(item['purpose'] as String? ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.urbanist(
                              fontSize: 11,
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${(item['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  //  Pickers / Bottom sheets
  // ===========================================================================
  Future<void> _pickDate(_LineItem item) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: item.date ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => item.date = picked);
  }

  void _showCategoryPicker(_LineItem item) {
    _showBottomSheetPicker(
      title: 'Select Category',
      children: MockExpenses.categories.map((cat) {
        final name = cat['name'] as String;
        final isSelected = item.categoryId == cat['id'];
        return _sheetOption(
          label: name,
          icon: _categoryIcon(name),
          isSelected: isSelected,
          onTap: () {
            setState(() {
              item.categoryId = cat['id'] as String;
              item.categoryName = name;
            });
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showPaymentTypePicker(_LineItem item) {
    _showBottomSheetPicker(
      title: 'Select Payment Type',
      children: MockExpenses.paymentTypes.map((pt) {
        final isSelected = item.paymentType == pt;
        return _sheetOption(
          label: pt,
          icon: PhosphorIconsRegular.creditCard,
          isSelected: isSelected,
          onTap: () {
            setState(() => item.paymentType = pt);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showBottomSheetPicker({
    required String title,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.urbanist(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: children,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mistBlue : AppColors.divider,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary)),
            ),
            if (isSelected)
              const Icon(PhosphorIconsFill.checkCircle,
                  size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  //  Reusable form helpers
  // ===========================================================================
  Widget _glassTextField({
    TextEditingController? controller,
    String? label,
    IconData? icon,
    String? initialValue,
    String? prefix,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label,
                style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary)),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(icon, size: 18, color: AppColors.textTertiary),
                ),
              if (prefix != null)
                Padding(
                  padding: EdgeInsets.only(left: icon != null ? 6 : 12),
                  child: Text(prefix,
                      style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  initialValue: controller == null ? initialValue : null,
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  maxLines: maxLines,
                  style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: icon != null || prefix != null ? 8 : 14,
                        vertical: 12),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _readOnlyField({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label,
              style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 8),
              ],
              Text(value,
                  style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassPickerField({
    required String label,
    String? value,
    required String placeholder,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(label,
              style: GoogleFonts.urbanist(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: AppColors.textTertiary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                const Icon(PhosphorIconsRegular.caretDown,
                    size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
      ],
    );
  }

  // ===========================================================================
  //  Utilities
  // ===========================================================================
  String _formatDateString(String isoDate) {
    try {
      final d = DateTime.parse(isoDate);
      return DateFormat('MMM d, yyyy').format(d);
    } catch (_) {
      return isoDate;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'meals':
        return PhosphorIconsRegular.forkKnife;
      case 'lodging':
        return PhosphorIconsRegular.bed;
      case 'airfare':
        return PhosphorIconsRegular.airplaneTilt;
      case 'ground transport':
        return PhosphorIconsRegular.car;
      case 'parking':
        return PhosphorIconsRegular.garage;
      case 'conference fees':
        return PhosphorIconsRegular.ticket;
      case 'supplies':
        return PhosphorIconsRegular.package;
      case 'mileage':
        return PhosphorIconsRegular.gauge;
      case 'communications':
        return PhosphorIconsRegular.phone;
      case 'miscellaneous':
        return PhosphorIconsRegular.receiptX;
      default:
        return PhosphorIconsRegular.receipt;
    }
  }
}

// =============================================================================
//  Success bottom sheet
// =============================================================================
class _SuccessSheet extends StatelessWidget {
  final String reportId;
  const _SuccessSheet({required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 28, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(PhosphorIconsBold.checkCircle,
                size: 32, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text('Report Submitted',
              style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Report $reportId submitted\nfor approval.',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Done',
            width: double.infinity,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
