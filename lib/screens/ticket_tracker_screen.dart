import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:gc_employee_app/theme/app_colors.dart';
import 'package:gc_employee_app/widgets/glass_card.dart';
import 'package:gc_employee_app/widgets/status_badge.dart';
import 'package:gc_employee_app/mock/mock_tickets.dart';

class TicketTrackerScreen extends StatefulWidget {
  final Map<String, dynamic>? ticket;

  const TicketTrackerScreen({super.key, this.ticket});

  @override
  State<TicketTrackerScreen> createState() => _TicketTrackerScreenState();
}

class _TicketTrackerScreenState extends State<TicketTrackerScreen> {
  late Map<String, dynamic> _ticket;
  late List<Map<String, dynamic>> _messages;
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket ?? Map<String, dynamic>.from(MockTickets.tickets[0]);
    _messages = List<Map<String, dynamic>>.from(
      (_ticket['messages'] as List).map((m) => Map<String, dynamic>.from(m)),
    );
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'author': 'You',
        'role': 'requester',
        'date': DateTime.now().toIso8601String(),
        'text': text,
      });
    });

    _replyController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatMessageDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _priorityBg(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.errorLight;
      case 'medium':
        return AppColors.warningLight;
      case 'low':
        return AppColors.infoLight;
      default:
        return AppColors.divider;
    }
  }

  // Status timeline steps
  static const _statusSteps = ['open', 'in_progress', 'resolved', 'closed'];

  int _statusIndex(String status) {
    final normalized = status.toLowerCase().replaceAll(' ', '_');
    final idx = _statusSteps.indexOf(normalized);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final status = (_ticket['status'] as String?) ?? 'open';
    final priority = (_ticket['priority'] as String?) ?? 'medium';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Content area
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader(status)),

                // Summary card
                SliverToBoxAdapter(child: _buildSummaryCard(priority)),

                // Status timeline
                SliverToBoxAdapter(child: _buildStatusTimeline(status)),

                // Description
                SliverToBoxAdapter(child: _buildDescription()),

                // Thread header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIcons.chatCircleDots(PhosphorIconsStyle.fill),
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Communication Thread',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_messages.length} messages',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Messages
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMessageBubble(_messages[index]),
                      childCount: _messages.length,
                    ),
                  ),
                ),

                // Bottom spacer
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          // Reply input
          _buildReplyBar(),
        ],
      ),
    );
  }

  Widget _buildHeader(String status) {
    return SafeArea(
      bottom: false,
      child: Padding(
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
              splashRadius: 22,
            ),
            const SizedBox(width: 4),
            Text(
              _ticket['id'] ?? '',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            StatusBadge(status: status),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String priority) {
    final category = (_ticket['category'] as String?) ?? '';
    final assignedTo = _ticket['assignedTo'] as String?;

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          Text(
            (_ticket['subject'] as String?) ?? '',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Category + Priority pills
          Row(
            children: [
              _buildPill(
                label: category,
                color: AppColors.primary,
                bgColor: AppColors.mistBlue,
                icon: PhosphorIcons.tag(PhosphorIconsStyle.fill),
              ),
              const SizedBox(width: 8),
              _buildPill(
                label: priority[0].toUpperCase() + priority.substring(1),
                color: _priorityColor(priority),
                bgColor: _priorityBg(priority),
                icon: PhosphorIcons.flag(PhosphorIconsStyle.fill),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dates row
          Row(
            children: [
              _buildInfoItem(
                icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular),
                label: 'Created',
                value: _formatDate(_ticket['createdDate'] ?? ''),
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular),
                label: 'Updated',
                value: _formatDate(_ticket['lastUpdated'] ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          Container(
            height: 1,
            color: AppColors.divider,
          ),
          const SizedBox(height: 12),

          // Assigned to
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: assignedTo != null
                      ? AppColors.primaryLight.withValues(alpha: 0.15)
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  PhosphorIcons.user(PhosphorIconsStyle.fill),
                  size: 16,
                  color: assignedTo != null
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assigned To',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    assignedTo ?? 'Unassigned',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: assignedTo != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Column(
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
            Text(
              value,
              style: GoogleFonts.urbanist(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(String status) {
    final currentIdx = _statusIndex(status);
    final labels = ['Open', 'In Progress', 'Resolved', 'Closed'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i <= currentIdx;
          final isCurrent = i == currentIdx;

          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : AppColors.border,
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isCurrent ? 22 : 16,
                      height: isCurrent ? 22 : 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? AppColors.primary : AppColors.border,
                        border: isCurrent
                            ? Border.all(
                                color: AppColors.primaryLight.withValues(alpha: 0.4),
                                width: 3,
                              )
                            : null,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isActive
                          ? Icon(
                              isCurrent
                                  ? PhosphorIcons.circle(PhosphorIconsStyle.fill)
                                  : PhosphorIcons.check(PhosphorIconsStyle.bold),
                              size: isCurrent ? 10 : 10,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      labels[i],
                      style: GoogleFonts.urbanist(
                        fontSize: 9,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (i < labels.length - 1 && i == 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: (i + 1) <= currentIdx
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDescription() {
    final description = (_ticket['description'] as String?) ?? '';
    if (description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.article(PhosphorIconsStyle.fill),
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final role = (message['role'] as String?) ?? 'requester';
    final isRequester = role == 'requester';
    final author = (message['author'] as String?) ?? '';
    final date = (message['date'] as String?) ?? '';
    final text = (message['text'] as String?) ?? '';

    final displayName = isRequester ? 'You' : author;
    final roleLabel = isRequester ? 'Requester' : 'Technician';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isRequester ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRequester) ...[
            // Technician avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.coolGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                PhosphorIcons.headset(PhosphorIconsStyle.fill),
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Bubble
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isRequester
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.glassWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isRequester ? 16 : 4),
                  bottomRight: Radius.circular(isRequester ? 4 : 16),
                ),
                border: Border.all(
                  color: isRequester
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.glassBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isRequester
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Author & role
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isRequester
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isRequester
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          roleLabel,
                          style: GoogleFonts.urbanist(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isRequester
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Message text
                  Text(
                    text,
                    style: GoogleFonts.urbanist(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Timestamp
                  Text(
                    _formatMessageDate(date),
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isRequester) ...[
            const SizedBox(width: 8),
            // Requester avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                PhosphorIcons.user(PhosphorIconsStyle.fill),
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        12,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TextField(
                controller: _replyController,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a reply...',
                  hintStyle: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendReply(),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendReply,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.fill),
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
