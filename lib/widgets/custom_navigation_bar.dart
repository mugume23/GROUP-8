import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Item representing a tab in the [CustomNavigationBar].
class CustomNavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CustomNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// A premium, animated, and floating custom bottom navigation bar
/// that elevates the app's aesthetic and user experience.
class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<CustomNavBarItem> items;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeThemeColor = activeColor ?? AppTheme.primaryColor;
    final inactiveThemeColor = inactiveColor ?? AppTheme.textGrey;
    final barBgColor = backgroundColor ?? AppTheme.cardWhite;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        color: barBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: activeThemeColor.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: _NavBarItemWidget(
                  item: item,
                  isActive: isActive,
                  activeColor: activeThemeColor,
                  inactiveColor: inactiveThemeColor,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItemWidget extends StatefulWidget {
  final CustomNavBarItem item;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarItemWidget({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  State<_NavBarItemWidget> createState() => _NavBarItemWidgetState();
}

class _NavBarItemWidgetState extends State<_NavBarItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _NavBarItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: widget.isActive
                ? _scaleAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? widget.activeColor.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.isActive ? widget.item.activeIcon : widget.item.icon,
                color: widget.isActive ? widget.activeColor : widget.inactiveColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
              color: widget.isActive ? widget.activeColor : widget.inactiveColor,
              fontFamily: 'Poppins',
            ),
            child: Text(widget.item.label),
          ),
          const SizedBox(height: 4),
          // Animated dot indicator at the bottom
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: widget.isActive ? 5 : 0,
            height: 5,
            decoration: BoxDecoration(
              color: widget.activeColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
