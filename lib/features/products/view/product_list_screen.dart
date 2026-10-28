import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/product_model.dart';
import '../../shared/widgets/app_shell.dart';
import '../controller/product_controller.dart';
import '../widgets/stock_indicator_chip.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return AppShell(
      title: 'Products',
      currentIndex: 1,
      actions: [
        Obx(
          () => controller.selectedStatus.value == 'Inactive'
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.setSelectedProduct(null);
                      Get.toNamed(AppRoutes.addProduct);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ),
        ),
      ],
      child: const _ProductListBody(),
    );
  }
}

class _ProductListBody extends GetView<ProductController> {
  const _ProductListBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: Column(
        children: [
          const _ProductToolbar(),
          const SizedBox(height: 14),
          Obx(() => controller.isActionProcessing.value
              ? const LinearProgressIndicator(minHeight: 2)
              : const SizedBox.shrink()),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredProducts.isEmpty) {
                return const _EmptyProductsState();
              }
              return AbsorbPointer(
                absorbing: controller.isActionProcessing.value,
                child: const _ProductTable(),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductToolbar extends GetView<ProductController> {
  const _ProductToolbar();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        return Column(
          children: [
            TextField(
              onChanged: controller.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search by name, SKU, or category',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  Obx(
                    () => SizedBox(
                      width: isCompact ? 130 : 150,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: controller.selectedStatus.value,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                        ),
                        items: controller.statusFilters
                            .map(
                              (status) => DropdownMenuItem(
                                  value: status, child: Text(status)),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSelectedStatus(value);
                          }
                        },
                      ),
                    ),
                  ),
                  Obx(
                    () => SizedBox(
                      width: isCompact ? 130 : 170,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: controller.selectedCategory.value,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                        ),
                        items: controller.categories
                            .map(
                              (category) => DropdownMenuItem(
                                  value: category, child: Text(category)),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSelectedCategory(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductTable extends GetView<ProductController> {
  const _ProductTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Obx(() {
          final products = controller.filteredProducts.toList(growable: false);

          return PaginatedDataTable2(
            minWidth: 1040,
            smRatio: 0.85,
            lmRatio: 1.55,
            dataRowHeight: 66,
            showCheckboxColumn: false,
            columns: const [
              DataColumn2(label: Text('Product'), size: ColumnSize.L),
              DataColumn2(label: Text('SKU'), size: ColumnSize.S),
              DataColumn2(label: Text('Category'), size: ColumnSize.M),
              DataColumn2(label: Text('Quantity'), size: ColumnSize.S),
              DataColumn2(label: Text('Minimum'), size: ColumnSize.S),
              DataColumn2(label: Text('Price'), size: ColumnSize.S),
              DataColumn2(label: Text('Actions'), size: ColumnSize.S),
            ],
            source: _ProductTableSource(products, controller),
            rowsPerPage: 10,
            availableRowsPerPage: const [10, 20, 30],
            columnSpacing: 14,
            horizontalMargin: 8,
            headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
            renderEmptyRowsInTheEnd: false,
          );
        }),
      ),
    );
  }
}

class _ProductTableSource extends DataTableSource {
  _ProductTableSource(this.products, this.controller);

  final List<ProductModel> products;
  final ProductController controller;

  @override
  DataRow getRow(int index) {
    if (index >= products.length) {
      return DataRow(
          cells: List.generate(7, (_) => const DataCell(SizedBox.shrink())));
    }

    final product = products[index];

    return DataRow2(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: product.isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!product.isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Inactive',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(product.sku)),
        DataCell(Text(product.category)),
        DataCell(
          Align(
            alignment: Alignment.centerLeft,
            child: StockIndicatorChip(product: product),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(product.minimumLevel.toString()),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(AppUtils.formatCurrency(product.price)),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconActionButton(
                tooltip: 'Edit',
                icon: Icons.edit_outlined,
                color: AppColors.primary,
                onTap: () {
                  controller.setSelectedProduct(product);
                  Get.toNamed(AppRoutes.editProduct);
                },
              ),
              const SizedBox(width: 6),
              _IconActionButton(
                tooltip: product.isActive ? 'Deactivate' : 'Reactivate',
                icon: product.isActive
                    ? Icons.visibility_off_outlined
                    : Icons.restore_rounded,
                color: product.isActive ? AppColors.warning : AppColors.success,
                onTap: () => product.isActive
                    ? _confirmDeactivate(product)
                    : _confirmReactivate(product),
              ),
              const SizedBox(width: 6),
              _IconActionButton(
                tooltip: 'Delete',
                icon: Icons.delete_outline,
                color: AppColors.error,
                onTap: () => _confirmDelete(product),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeactivate(ProductModel product) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Deactivate product'),
        content:
            const Text('Are you sure you want to deactivate this product?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Deactivate')),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deactivateProduct(product.id);
    }
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteProduct(product.id);
    }
  }

  Future<void> _confirmReactivate(ProductModel product) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reactivate product'),
        content:
            const Text('Are you sure you want to reactivate this product?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Reactivate')),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.reactivateProduct(product.id);
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
      ),
    );
  }
}

class _EmptyProductsState extends GetView<ProductController> {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 70, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          const Text('No products found',
              style: TextStyle(color: AppColors.textSecondary)),
          if (controller.selectedStatus.value != 'Inactive') ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                controller.setSelectedProduct(null);
                Get.toNamed(AppRoutes.addProduct);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            ),
          ],
        ],
      ),
    );
  }
}
