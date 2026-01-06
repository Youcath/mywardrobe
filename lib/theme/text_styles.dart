import 'package:flutter/material.dart';

class AppTextStyles {
  // Princess Theme Text Styles
  static const princessTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: 'Georgia', // Using standard serif for elegance if specific font not available
    color: Color(0xFFFF69B4),
  );

  static const princessBody = TextStyle(
    fontSize: 16,
    fontFamily: 'Verdana',
    color: Color(0xFF4A4A4A),
  );

  // Queen Theme Text Styles
  static const queenTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    color: Color(0xFFB76E79), // Rose Gold
  );

  static const queenBody = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
  );

  // Minimalist Theme Text Styles
  static const minimalTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
    color: Color(0xFF424242),
  );

  static const minimalBody = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: Colors.black87,
  );
}




