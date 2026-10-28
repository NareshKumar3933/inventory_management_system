import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/product_model.dart';

class StockIndicatorChip extends StatelessWidget {
  const StockIndicatorChip({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (product.quantity <= 0) {
      color = AppColors.error;
    } else if (product.isLowStock) {
      color = AppColors.warning;
    } else {
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        product.quantity.toString(),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

