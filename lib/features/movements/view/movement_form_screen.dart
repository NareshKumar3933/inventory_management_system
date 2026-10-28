import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/movement_model.dart';
import '../../../data/models/product_model.dart';
import '../../shared/widgets/app_shell.dart';
import '../controller/movement_controller.dart';

class MovementFormScreen extends StatefulWidget {
  const MovementFormScreen({super.key});

  @override
  State<MovementFormScreen> createState() => _MovementFormScreenState();
}

class _MovementFormScreenState extends State<MovementFormScreen> {
  final MovementController _controller = Get.find<MovementController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Record Movement',
      currentIndex: 2,
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
                    constraints: const BoxConstraints(maxWidth: 720),
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
                            Text('New inventory movement',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 6),
                            const Text(
                              'Stock quantity will be updated through the service layer.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            const _Label('Movement Type *'),
                            const SizedBox(height: 8),
                            const _TypeSelector(),
                            const SizedBox(height: 14),
                            const _Label('Product *'),
                            const SizedBox(height: 8),
                            const _ProductSelector(),
                            const SizedBox(height: 14),
                            Obx(() {
                              final isAdjustment =
                                  _controller.selectedType.value ==
                                      MovementType.adjustment;
                              return _LabeledTextField(
                                label: isAdjustment
                                    ? 'New Quantity *'
                                    : 'Quantity *',
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                hint: isAdjustment
                                    ? 'Set absolute stock level'
                                    : 'Enter movement quantity',
                                validator: (value) {
                                  final parsed = int.tryParse(value ?? '');
                                  if (parsed == null || parsed < 0) {
                                    return 'Please enter a valid quantity.';
                                  }
                                  if (!isAdjustment && parsed == 0) {
                                    return 'Quantity must be greater than zero.';
                                  }
                                  return null;
                                },
                              );
                            }),
                            const SizedBox(height: 14),
                            _LabeledTextField(
                              label: 'Note (optional)',
                              controller: _noteController,
                              maxLines: 3,
                              hint: 'Optional note for this movement',
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
                                    icon:
                                        const Icon(Icons.check_circle_outline),
                                    label: const Text('Record Movement'),
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

    final movementLabel = _controller.selectedType.value.label;
    final success = await _controller.recordMovement(
      rawQuantity: _quantityController.text,
      note: _noteController.text,
    );

    if (success) {
      Get.back();
      Future<void>.delayed(const Duration(milliseconds: 10), () {
        AppSnackbar.show(
          title: 'Inventory',
          message: '$movementLabel recorded successfully.',
          type: AppSnackbarType.success,
        );
      });
    }
  }
}

class _TypeSelector extends GetView<MovementController> {
  const _TypeSelector();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedType = controller.selectedType.value;

      return Row(
        children: MovementType.values.map((type) {
          final selected = selectedType == type;
          final color = _typeColor(type);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => controller.setSelectedType(type),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withOpacity(0.12)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: selected ? color : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(_typeIcon(type),
                          color: selected ? color : AppColors.textSecondary),
                      const SizedBox(height: 6),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: selected ? color : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
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
}

class _ProductSelector extends GetView<MovementController> {
  const _ProductSelector();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedProduct = controller.selectedProduct.value;

      return DropdownButtonFormField<ProductModel>(
        value: selectedProduct,
        decoration:
            const InputDecoration(prefixIcon: Icon(Icons.inventory_2_outlined)),
        isExpanded: true,
        items: controller.products.map((product) {
          return DropdownMenuItem<ProductModel>(
            value: product,
            child: Text('${product.name} (Stock: ${product.quantity})',
                overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: controller.setSelectedProduct,
        validator: (value) => value == null ? 'Please select a product.' : null,
      );
    });
  }
}

class _Label extends StatelessWidget {
  const _Label(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.hint,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? hint;
  final String? Function(String?)? validator;

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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
