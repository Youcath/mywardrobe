import 'package:flutter/material.dart';

class OccasionCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  const OccasionCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    LinearGradient gradient;
    
    switch (title) {
      case '约会':
        gradient = const LinearGradient(
          colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case '上班':
        gradient = const LinearGradient(
          colors: [Color(0xFF87CEFA), Color(0xFF4682B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case '游玩':
        gradient = const LinearGradient(
          colors: [Color(0xFF90EE90), Color(0xFF32CD32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      default:
        gradient = const LinearGradient(
          colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count 套搭配',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




