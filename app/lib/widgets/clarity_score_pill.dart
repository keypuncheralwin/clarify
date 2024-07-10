import 'package:clarify/utils/clarity_score_calculator.dart';
import 'package:flutter/material.dart';

class ClarityScorePill extends StatelessWidget {
  final int clarityScore;

  const ClarityScorePill({
    super.key,
    required this.clarityScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: getClarityScoreColor(clarityScore),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Clarity Score: $clarityScore',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
