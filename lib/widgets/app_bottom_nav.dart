import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:gc_employee_app/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(
      label: 'Home',
      icon: PhosphorIconsStyle.regular,
      activeIcon: PhosphorIconsStyle.fill,
      iconName: 'house',
    ),
    _NavItem(
      label: 'Travel',
      icon: PhosphorIconsStyle.regular,
      activeIcon: PhosphorIconsStyle.fill,
      iconName: 'airplane-tilt',
    ),
    _NavItem(
      label: 'Expenses',
      icon: PhosphorIconsStyle.regular,
      activeIcon: PhosphorIconsStyle.fill,
      iconName: 'receipt',
    ),
    _NavItem(
      label: 'Devices',
      icon: PhosphorIconsStyle.regular,
      activeIcon: PhosphorIconsStyle.fill,
      iconName: 'laptop',
    ),
    _NavItem(
      label: 'Support',
      icon: PhosphorIconsStyle.regular,
      activeIcon: PhosphorIconsStyle.fill,
      iconName: 'headset',
    ),
  ];

  PhosphorIconData _getIcon(int index, bool isActive) {
    final style = isActive ? PhosphorIconsStyle.fill : PhosphorIconsStyle.regular;
    switch (index) {
      case 0:
        return PhosphorIcons.house(style);
      case 1:
        return PhosphorIcons.airplaneTilt(style);
      case 2:
        return PhosphorIcons.receipt(style);
      case 3:
        return PhosphorIcons.laptop(style);
      case 4:
        return PhosphorIcons.headset(style);
      default:
        return PhosphorIcons.house(style);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          bottom: bottomPadding + 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final isActive = index == currentIndex;
            return _buildNavItem(index, isActive);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isActive) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(index, isActive),
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              _items[index].label,
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            // Dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isActive ? 5 : 0,
              height: isActive ? 5 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final PhosphorIconsStyle icon;
  final PhosphorIconsStyle activeIcon;
  final String iconName;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.iconName,
  });
}
