import 'package:flutter/material.dart';

Color getClarityScoreColor(int score) {
  if (score >= 0 && score <= 4) {
    return const Color(0xFFfe2712); // Red for low scores
  } else if (score >= 5 && score <= 6) {
    return const Color(0xFFfb9902); // Orange for medium scores
  } else if (score >= 7 && score <= 10) {
    return const Color(0xFF66b032); // Green for high scores
  } else {
    return Colors.grey; // Default color for invalid scores
  }
}
