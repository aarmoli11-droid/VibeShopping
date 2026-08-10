import 'package:flutter/material.dart';
import '../../../core/vibe_constants.dart';
import '../../../core/vibe_formatter.dart';
import '../models/comparison_summary.dart';

class ComparisonSummaryCard extends StatelessWidget {
  final ComparisonSummary summary;

  const ComparisonSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VibeColors.mint.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _Metric(
            label: 'Mejor precio',
            value: VibeFormatter.formatPrice(summary.cheapestPrice),
          ),
          _Divider(),
          _Metric(
            label: 'Ahorro',
            value: VibeFormatter.formatPrice(summary.savings),
          ),
          _Divider(),
          _Metric(
            label: 'Diferencia',
            value: '${summary.percentageDifference.round()}%',
          ),
          _Divider(),
          _Metric(
            label: 'Supermercados',
            value: '${summary.supermarketsCompared}',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: VibeColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: VibeColors.navy.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: VibeColors.mint.withValues(alpha: 0.3),
    );
  }
}
