import 'package:flutter/material.dart';
import '../theme/color_schemes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Container(
      height: 80, // 稍微降低高度，更加清爽
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // 极淡的阴影
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none, // 允许装饰元素稍微溢出
        alignment: Alignment.center,
        children: [
          // 背景修饰：为中间按钮提供一个“底座”感
          Positioned(
            top: -12,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.checkroom_rounded, Icons.checkroom_outlined, '衣橱'),
              _buildNavItem(context, 1, Icons.auto_awesome_rounded, Icons.auto_awesome_outlined, '穿搭'),
              const SizedBox(width: 50), // 为中间按钮留出合适空间
              _buildNavItem(context, 3, Icons.calendar_month_rounded, Icons.calendar_month_outlined, '日历'),
              _buildNavItem(context, 4, Icons.person_rounded, Icons.person_outline_rounded, '个人'),
            ],
          ),

          // 优化后的中间按钮
          Positioned(
            top: -8, // 降低高度，不再突兀
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: theme.extension<ThemeGradients>()?.primaryGradient ?? 
                    LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3), // 主题色光晕
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.15 : 1.0,
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? theme.colorScheme.primary : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? theme.colorScheme.primary : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
