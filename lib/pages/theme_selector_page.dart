import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_themes.dart';
import '../theme/color_schemes.dart';

class ThemeSelectorPage extends StatelessWidget {
  const ThemeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主题设置')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildThemeCard(
            context,
            type: AppThemeType.princess,
            name: '公主风',
            description: '粉色梦幻，圆润优雅',
            colors: [AppColors.princessPrimaryStart, AppColors.princessPrimaryEnd],
          ),
          const SizedBox(height: 20),
          _buildThemeCard(
            context,
            type: AppThemeType.queen,
            name: '御姐风',
            description: '高级深紫，冷艳魅力',
            colors: [AppColors.queenPrimaryStart, AppColors.queenPrimaryEnd],
          ),
          const SizedBox(height: 20),
          _buildThemeCard(
            context,
            type: AppThemeType.minimalist,
            name: '简约风',
            description: '极简留白，清爽自然',
            colors: [AppColors.minimalPrimaryStart, AppColors.minimalPrimaryEnd],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required AppThemeType type,
    required String name,
    required String description,
    required List<Color> colors,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.currentThemeType == type;

    return GestureDetector(
      onTap: () => themeProvider.setTheme(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors[0].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors[0] : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                shape: BoxShape.circle,
              ),
              child: isSelected 
                  ? const Icon(Icons.check, color: Colors.white) 
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colors[0],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '当前使用',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}




