import 'package:flutter/material.dart';
import '../theme/color_schemes.dart';

class CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final Map<String, IconData> categories;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeGradient = theme.extension<ThemeGradients>()?.primaryGradient;

    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: themeGradient ?? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
            (theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary).withOpacity(0.8),
          ],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories.keys.elementAt(index);
          final icon = categories[cat]!;
          final isSelected = selectedCategory == cat;

          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.1 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? theme.colorScheme.primary : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.primary : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

