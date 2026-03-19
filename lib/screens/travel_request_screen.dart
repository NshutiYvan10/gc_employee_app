import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/gradient_button.dart';
import 'package:gc_employee_app/widgets/gradient_background.dart';
import 'package:gc_employee_app/mock/mock_travel.dart';
import 'package:gc_employee_app/mock/mock_users.dart';

class TravelRequestScreen extends StatefulWidget {
  const TravelRequestScreen({super.key});

  @override
  State<TravelRequestScreen> createState() => _TravelRequestScreenState();
}

class _TravelRequestScreenState extends State<TravelRequestScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1 controllers
  final _purposeController = TextEditingController();
  final _destinationController = TextEditingController();
  final _costCenterController = TextEditingController();
  DateTime? _departureDate;
  DateTime? _returnDate;

  // Step 2 controllers
  final _airfareController = TextEditingController();
  final _lodgingController = TextEditingController();
  final _mealsController = TextEditingController();
  final _otherController = TextEditingController();

  late AnimationController _stepAnimController;
  late Animation<double> _stepFadeAnim;

  final List<String> _stepLabels = [
    'Trip Details',
    'Cost Estimate',
    'Review & Submit',
  ];

  @override
  void initState() {
    super.initState();
    _costCenterController.text =
        MockUser.currentUser['costCenter'] as String? ?? '';

    final now = DateTime.now();
    _departureDate = now.add(const Duration(days: 14));
    _returnDate = now.add(const Duration(days: 18));

    _stepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _stepFadeAnim = CurvedAnimation(
      parent: _stepAnimController,
      curve: Curves.easeInOut,
    );
    _stepAnimController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _purposeController.dispose();
    _destinationController.dispose();
    _costCenterController.dispose();
    _airfareController.dispose();
    _lodgingController.dispose();
    _mealsController.dispose();
    _otherController.dispose();
    _stepAnimController.dispose();
    super.dispose();
  }

  int get _tripDays {
    if (_departureDate != null && _returnDate != null) {
      return _returnDate!.difference(_departureDate!).inDays;
    }
    return 0;
  }

  double get _estimatedMeals => _tripDays * 69.0;

  double _parseAmount(String text) {
    return double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  double get _estimatedTotal {
    return _parseAmount(_airfareController.text) +
        _parseAmount(_lodgingController.text) +
        _estimatedMeals +
        _parseAmount(_otherController.text);
  }

  double get _remainingBudget =>
      (MockTravel.budget['remaining'] as double?) ?? 3416.0;

  double get _projectedRemaining => _remainingBudget - _estimatedTotal;

  bool get _isOverBudget => _projectedRemaining < 0;

  bool _validateStep1() {
    return _purposeController.text.trim().isNotEmpty &&
        _destinationController.text.trim().isNotEmpty &&
        _departureDate != null &&
        _returnDate != null;
  }

  bool _validateStep2() {
    return _parseAmount(_airfareController.text) > 0 ||
        _parseAmount(_lodgingController.text) > 0 ||
        _parseAmount(_otherController.text) > 0;
  }

  void _goToStep(int step) {
    if (step < 0 || step > 2) return;
    _stepAnimController.reset();
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
    setState(() => _currentStep = step);
    _stepAnimController.forward();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) {
      _showValidationError('Please fill in all trip detail fields.');
      return;
    }
    if (_currentStep == 1 && !_validateStep2()) {
      _showValidationError('Please enter at least one cost estimate.');
      return;
    }
    // Auto-calc meals when moving from step 2
    if (_currentStep == 1) {
      _mealsController.text = _estimatedMeals.toStringAsFixed(2);
    }
    _goToStep(_currentStep + 1);
  }

  void _previousStep() {
    _goToStep(_currentStep - 1);
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Future<void> _submitRequest() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final requestId =
        'TR-2026-${(Random().nextInt(900) + 100).toString().padLeft(3, '0')}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => _SuccessSheet(requestId: requestId),
    );
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    final now = DateTime.now();
    final initial = isDeparture
        ? (_departureDate ?? now.add(const Duration(days: 14)))
        : (_returnDate ?? now.add(const Duration(days: 18)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textTheme: GoogleFonts.urbanistTextTheme(),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
          if (_returnDate != null && _returnDate!.isBefore(picked)) {
            _returnDate = picked.add(const Duration(days: 1));
          }
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildStepIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                PhosphorIconsRegular.caretLeft,
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
                  'New Travel Request',
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _stepLabels[_currentStep],
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${_currentStep + 1}/3',
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: isCompleted ? () => _goToStep(index) : null,
              child: Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 32 : 26,
                    height: isActive ? 32 : 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.primary
                          : isActive
                              ? AppColors.primary
                              : AppColors.surface,
                      border: Border.all(
                        color: isCompleted || isActive
                            ? AppColors.primary
                            : AppColors.border,
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              PhosphorIconsBold.check,
                              size: 13,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textTertiary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Trip Details ──────────────────────────────────────────

  Widget _buildStep1() {
    return FadeTransition(
      opacity: _stepFadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Purpose of Travel'),
            GlassCard(
              padding: const EdgeInsets.all(4),
              child: _buildTextField(
                controller: _purposeController,
                hint: 'e.g. Division Year-End Audit Review',
                icon: PhosphorIconsRegular.notepad,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 4),
            _buildSectionLabel('Destination'),
            GlassCard(
              padding: const EdgeInsets.all(4),
              child: _buildTextField(
                controller: _destinationController,
                hint: 'e.g. Miami, FL (IAD Office)',
                icon: PhosphorIconsRegular.mapPin,
              ),
            ),
            const SizedBox(height: 4),
            _buildSectionLabel('Travel Dates'),
            GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Departure',
                      date: _departureDate,
                      icon: PhosphorIconsRegular.calendarBlank,
                      onTap: () => _pickDate(isDeparture: true),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: AppColors.divider,
                  ),
                  Expanded(
                    child: _buildDateField(
                      label: 'Return',
                      date: _returnDate,
                      icon: PhosphorIconsRegular.calendarCheck,
                      onTap: () => _pickDate(isDeparture: false),
                    ),
                  ),
                ],
              ),
            ),
            if (_tripDays > 0) ...[
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 6),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.clock,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_tripDays night${_tripDays == 1 ? '' : 's'}',
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 4),
            _buildSectionLabel('Cost Center'),
            GlassCard(
              padding: const EdgeInsets.all(4),
              backgroundColor: AppColors.mistBlue.withValues(alpha: 0.5),
              child: _buildTextField(
                controller: _costCenterController,
                hint: 'Cost Center',
                icon: PhosphorIconsRegular.buildings,
                enabled: false,
              ),
            ),
            const SizedBox(height: 24),
            _buildBottomNav(showBack: false),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Cost Estimate ─────────────────────────────────────────

  Widget _buildStep2() {
    return FadeTransition(
      opacity: _stepFadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        child: StatefulBuilder(
          builder: (context, setInnerState) {
            void onCostChanged() {
              setInnerState(() {});
              setState(() {});
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Estimated Costs'),
                GlassCard(
                  child: Column(
                    children: [
                      _buildCurrencyField(
                        controller: _airfareController,
                        label: 'Airfare',
                        icon: PhosphorIconsRegular.airplaneTilt,
                        onChanged: onCostChanged,
                      ),
                      _buildFieldDivider(),
                      _buildCurrencyField(
                        controller: _lodgingController,
                        label: 'Lodging',
                        icon: PhosphorIconsRegular.bed,
                        onChanged: onCostChanged,
                      ),
                      _buildFieldDivider(),
                      _buildMealsReadOnly(),
                      _buildFieldDivider(),
                      _buildCurrencyField(
                        controller: _otherController,
                        label: 'Other',
                        icon: PhosphorIconsRegular.dotsThreeOutline,
                        onChanged: onCostChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildBudgetImpactCard(),
                const SizedBox(height: 24),
                _buildBottomNav(showBack: true),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMealsReadOnly() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              PhosphorIconsRegular.forkKnife,
              size: 18,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meals (per diem)',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_tripDays day${_tripDays == 1 ? '' : 's'} x \$69/day',
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${_estimatedMeals.toStringAsFixed(2)}',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetImpactCard() {
    final total = _estimatedTotal;
    final projected = _projectedRemaining;
    final isOver = _isOverBudget;

    return GlassCard(
      backgroundColor: isOver
          ? AppColors.errorLight.withValues(alpha: 0.6)
          : AppColors.successLight.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsBold.chartPieSlice,
                size: 18,
                color: isOver ? AppColors.error : AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'Budget Impact',
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBudgetRow(
            'Remaining Budget',
            '\$${_remainingBudget.toStringAsFixed(2)}',
            AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          _buildBudgetRow(
            'Estimated Total',
            '- \$${total.toStringAsFixed(2)}',
            AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: isOver
                ? AppColors.error.withValues(alpha: 0.2)
                : AppColors.success.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 10),
          _buildBudgetRow(
            'Projected Remaining',
            '${projected < 0 ? '-' : ''}\$${projected.abs().toStringAsFixed(2)}',
            isOver ? AppColors.error : AppColors.success,
            isBold: true,
          ),
          if (isOver) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsBold.warning,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This request exceeds your remaining travel budget. Manager approval will be required.',
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

  Widget _buildBudgetRow(String label, String value, Color valueColor,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── Step 3: Review & Submit ───────────────────────────────────────

  Widget _buildStep3() {
    return FadeTransition(
      opacity: _stepFadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Trip Summary'),
            GlassCard(
              child: Column(
                children: [
                  _buildReviewRow(
                    PhosphorIconsRegular.notepad,
                    'Purpose',
                    _purposeController.text,
                  ),
                  _buildFieldDivider(),
                  _buildReviewRow(
                    PhosphorIconsRegular.mapPin,
                    'Destination',
                    _destinationController.text,
                  ),
                  _buildFieldDivider(),
                  _buildReviewRow(
                    PhosphorIconsRegular.calendarBlank,
                    'Dates',
                    '${_formatDate(_departureDate)} — ${_formatDate(_returnDate)}',
                  ),
                  _buildFieldDivider(),
                  _buildReviewRow(
                    PhosphorIconsRegular.clock,
                    'Duration',
                    '$_tripDays night${_tripDays == 1 ? '' : 's'}',
                  ),
                  _buildFieldDivider(),
                  _buildReviewRow(
                    PhosphorIconsRegular.buildings,
                    'Cost Center',
                    _costCenterController.text,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _buildSectionLabel('Cost Breakdown'),
            GlassCard(
              child: Column(
                children: [
                  _buildCostReviewRow(
                      'Airfare', _parseAmount(_airfareController.text)),
                  _buildFieldDivider(),
                  _buildCostReviewRow(
                      'Lodging', _parseAmount(_lodgingController.text)),
                  _buildFieldDivider(),
                  _buildCostReviewRow('Meals (per diem)', _estimatedMeals),
                  _buildFieldDivider(),
                  _buildCostReviewRow(
                      'Other', _parseAmount(_otherController.text)),
                  const SizedBox(height: 10),
                  Container(height: 1, color: AppColors.divider),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Estimated Cost',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '\$${_estimatedTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.urbanist(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _buildBudgetImpactCard(),
            const SizedBox(height: 12),
            GlassCard(
              backgroundColor: AppColors.infoLight.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    PhosphorIconsRegular.info,
                    size: 18,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'By submitting, this request will be routed to your manager for approval.',
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  GradientButton(
                    text: 'Submit Request',
                    icon: PhosphorIconsBold.paperPlaneTilt,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submitRequest,
                    width: double.infinity,
                    height: 54,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _previousStep,
                    child: Text(
                      'Back to Cost Estimate',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.mistBlue.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
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
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
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
      ),
    );
  }

  Widget _buildCostReviewRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared Builders ───────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 4, top: 12),
      child: Text(
        text,
        style: GoogleFonts.urbanist(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: GoogleFonts.urbanist(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
        ),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatDate(date),
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              Icon(
                PhosphorIconsRegular.caretDown,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lavender.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              textAlign: TextAlign.right,
              onChanged: (_) => onChanged(),
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
                prefixText: '\$ ',
                prefixStyle: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: AppColors.divider,
    );
  }

  Widget _buildBottomNav({required bool showBack}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GradientButton(
            text: 'Continue',
            icon: PhosphorIconsBold.arrowRight,
            onPressed: _nextStep,
            width: double.infinity,
            height: 54,
          ),
          if (showBack) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _previousStep,
              child: Text(
                'Back',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Success Bottom Sheet ──────────────────────────────────────────

class _SuccessSheet extends StatefulWidget {
  final String requestId;
  const _SuccessSheet({required this.requestId});

  @override
  State<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<_SuccessSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.successGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                PhosphorIconsBold.check,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                Text(
                  'Request Submitted!',
                  style: GoogleFonts.urbanist(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mistBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.requestId,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your travel request has been submitted and is pending manager approval.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: 'Done',
            onPressed: () {
              Navigator.of(context).pop(); // close sheet
              Navigator.of(context).pop(); // go back
            },
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}
