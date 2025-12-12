import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Animate the initially selected item
    if (widget.currentIndex >= 0 && widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reverse old animation
      if (oldWidget.currentIndex >= 0 && oldWidget.currentIndex < _controllers.length) {
        _controllers[oldWidget.currentIndex].reverse();
      }
      // Forward new animation
      if (widget.currentIndex >= 0 && widget.currentIndex < _controllers.length) {
        _controllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap(int index) {
    // Haptic feedback
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.map_rounded,
                label: 'Map',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.auto_awesome_rounded,
                label: 'My AI',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animation and background
              Stack(
                alignment: Alignment.center,
                children: [
                  // Active indicator (pill background)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: isSelected ? 50 : 0,
                    height: isSelected ? 28 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.safetyBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  // Icon with scale animation
                  ScaleTransition(
                    scale: _animations[index],
                    child: Icon(
                      icon,
                      size: 24,
                      color: isSelected
                          ? AppColors.safetyBlue
                          : Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              // Label with fade animation
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.safetyBlue
                      : Theme.of(context).unselectedWidgetColor,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
