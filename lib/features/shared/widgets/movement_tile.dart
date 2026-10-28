import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/movement_model.dart';

class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.movement});

  final MovementModel movement;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(movement.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.55),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(_typeIcon(movement.type), color: color, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (movement.note.trim().isNotEmpty)
                  Text(
                    movement.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      _compactTypeCode(movement.type),
                      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 10),
                    ),
                  ),
                ),
                Text(
                  movement.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(MovementType type) {
    switch (type) {
      case MovementType.inward:
        return AppColors.stockIn;
      case MovementType.outward:
        return AppColors.stockOut;
      case MovementType.adjustment:
        return AppColors.stockAdjustment;
    }
  }

  IconData _typeIcon(MovementType type) {
    switch (type) {
      case MovementType.inward:
        return Icons.arrow_downward_rounded;
      case MovementType.outward:
        return Icons.arrow_upward_rounded;
      case MovementType.adjustment:
        return Icons.tune_rounded;
    }
  }

  String _compactTypeCode(MovementType type) {
    switch (type) {
      case MovementType.inward:
        return 'IN';
      case MovementType.outward:
        return 'OUT';
      case MovementType.adjustment:
        return 'ADJ';
    }
  }
}
