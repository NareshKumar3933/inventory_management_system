import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../shared/widgets/app_shell.dart';
import '../controller/product_controller.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, required this.isEditing});

  final bool isEditing;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final ProductController _controller = Get.find<ProductController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _categoryController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minimumLevelController;
  late final TextEditingController _priceController;

  String? get _editingId => _controller.selectedProduct.value?.id;

  @override
  void initState() {
    super.initState();

    if (!widget.isEditing) {
      _controller.setSelectedProduct(null);
    }

    final selectedProduct =
        widget.isEditing ? _controller.selectedProduct.value : null;

    _nameController = TextEditingController(text: selectedProduct?.name ?? '');
    _skuController = TextEditingController(text: selectedProduct?.sku ?? '');
    _categoryController =
        TextEditingController(text: selectedProduct?.category ?? '');
    _quantityController = TextEditingController(
      text:
          widget.isEditing ? (selectedProduct?.quantity ?? 0).toString() : '0',
    );
    _minimumLevelController = TextEditingController(
      text: (selectedProduct?.minimumLevel ?? 5).toString(),
    );
    _priceController = TextEditingController(
      text: selectedProduct == null || selectedProduct.price == 0
          ? ''
          : selectedProduct.price.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _minimumLevelController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: widget.isEditing ? 'Edit Product' : 'Create Product',
      currentIndex: 1,
      child: Obx(
        () => Column(
          children: [
            if (_controller.isSubmitting.value)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isEditing
                                  ? 'Update product details'
                                  : 'Add a new product',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _LabeledField(
                              label: 'Product Name *',
                              child: TextFormField(
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Product name is required.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _LabeledField(
                                    label: 'SKU *',
                                    child: TextFormField(
                                      controller: _skuController,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'SKU is required.';
                                        }
                                        final exists = _controller.isSkuTaken(
                                          value,
                                          excludeId: widget.isEditing
                                              ? _editingId
                                              : null,
                                        );
                                        if (exists) {
                                          return 'SKU must be unique.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _LabeledField(
                                    label: 'Category *',
                                    child: TextFormField(
                                      controller: _categoryController,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Category is required.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                if (!widget.isEditing)
                                  Expanded(
                                    child: _LabeledField(
                                      label: 'Initial Quantity',
                                      child: TextFormField(
                                        controller: _quantityController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        validator: (value) {
                                          final parsed =
                                              int.tryParse(value ?? '');
                                          if (parsed == null || parsed < 0) {
                                            return 'Use zero or a positive quantity.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                if (!widget.isEditing)
                                  const SizedBox(width: 12),
                                Expanded(
                                  child: _LabeledField(
                                    label: 'Minimum Level *',
                                    child: TextFormField(
                                      controller: _minimumLevelController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      validator: (value) {
                                        final parsed =
                                            int.tryParse(value ?? '');
                                        if (parsed == null || parsed < 0) {
                                          return 'Use zero or a positive minimum level.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _LabeledField(
                                    label: 'Price (optional)',
                                    child: TextFormField(
                                      controller: _priceController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}')),
                                      ],
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return null;
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Invalid price format.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_controller.formError.value.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _controller.formError.value,
                                  style:
                                      const TextStyle(color: AppColors.error),
                                ),
                              ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _controller.isSubmitting.value
                                        ? null
                                        : _submit,
                                    icon: Icon(widget.isEditing
                                        ? Icons.save_outlined
                                        : Icons.add_circle_outline),
                                    label: Text(widget.isEditing
                                        ? 'Save Changes'
                                        : 'Create Product'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _controller.isSubmitting.value
                                        ? null
                                        : Get.back,
                                    child: const Text('Cancel'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final minimumLevel = int.parse(_minimumLevelController.text.trim());
    final price = double.tryParse(_priceController.text.trim()) ?? 0;

    bool success;

    if (widget.isEditing) {
      final productId = _editingId;
      if (productId == null) {
        AppSnackbar.show(
          title: 'Inventory',
          message: 'No product selected for editing.',
          type: AppSnackbarType.error,
        );
        return;
      }

      success = await _controller.updateProduct(
        id: productId,
        name: _nameController.text,
        sku: _skuController.text,
        category: _categoryController.text,
        minimumLevel: minimumLevel,
        price: price,
        imagePath: '',
      );
    } else {
      final quantity = int.parse(_quantityController.text.trim());
      success = await _controller.createProduct(
        name: _nameController.text,
        sku: _skuController.text,
        category: _categoryController.text,
        quantity: quantity,
        minimumLevel: minimumLevel,
        price: price,
        imagePath: '',
      );
    }

    if (success) {
      Get.offNamed(AppRoutes.products);
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        AppSnackbar.show(
          title: 'Inventory',
          message: widget.isEditing
              ? 'Product updated successfully.'
              : 'Product created successfully.',
          type: AppSnackbarType.success,
        );
      });
    }
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
