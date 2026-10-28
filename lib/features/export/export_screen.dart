import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../shared/widgets/app_shell.dart';
import 'export_controller.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      title: 'Export CSV',
      currentIndex: 3,
      child: _ExportBody(),
    );
  }
}

class _ExportBody extends GetView<ExportController> {
  const _ExportBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export records to CSV files',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _ExportCard(
              title: 'Products CSV',
              subtitle: '${controller.productCount.value} products',
              icon: Icons.inventory_2_rounded,
              color: AppColors.primary,
              description: 'name, sku, category, quantity, minimumLevel, price',
              loading: controller.isExportingProducts.value,
              onTap: controller.exportProducts,
            ),
            const SizedBox(height: 12),
            _ExportCard(
              title: 'Movements CSV',
              subtitle: '${controller.movementCount.value} records',
              icon: Icons.swap_horiz_rounded,
              color: AppColors.info,
              description: 'productName, type, quantity, date, note',
              loading: controller.isExportingMovements.value,
              onTap: controller.exportMovements,
            ),
            const SizedBox(height: 16),
            if (controller.statusMessage.value.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Text(
                  controller.statusMessage.value,
                  style: const TextStyle(color: AppColors.success),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Web: download starts automatically. Desktop: file is saved in your documents directory.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
    required this.loading,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;
  final bool loading;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                ),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: loading ? null : onTap,
            icon: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

