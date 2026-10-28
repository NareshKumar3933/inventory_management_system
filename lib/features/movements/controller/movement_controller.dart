import 'package:get/get.dart';

import '../../../data/models/movement_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/movement_service.dart';
import '../../../data/services/product_service.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../products/controller/product_controller.dart';

class MovementController extends GetxController {
  final MovementService _movementService = MovementService.instance;
  final ProductService _productService = ProductService.instance;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString formError = ''.obs;

  final RxList<MovementModel> movements = <MovementModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  final Rx<MovementType> selectedType = MovementType.inward.obs;
  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    movements.assignAll(_movementService.getAllMovements());
    products.assignAll(_productService.getAllProducts());
    isLoading.value = false;
  }

  void setSelectedType(MovementType type) {
    selectedType.value = type;
  }

  void setSelectedProduct(ProductModel? product) {
    selectedProduct.value = product;
  }

  Future<bool> recordMovement({
    required String rawQuantity,
    String note = '',
  }) async {
    formError.value = '';

    final product = selectedProduct.value;
    if (product == null) {
      formError.value = 'Please select a product.';
      return false;
    }

    final quantity = int.tryParse(rawQuantity.trim());
    if (quantity == null || quantity < 0) {
      formError.value = 'Please enter a valid quantity.';
      return false;
    }

    if (selectedType.value != MovementType.adjustment && quantity == 0) {
      formError.value = 'Quantity must be greater than zero.';
      return false;
    }

    isSubmitting.value = true;

    try {
      switch (selectedType.value) {
        case MovementType.inward:
          await _movementService.recordStockIn(
            productId: product.id,
            quantity: quantity,
            note: note,
          );
          break;
        case MovementType.outward:
          await _movementService.recordStockOut(
            productId: product.id,
            quantity: quantity,
            note: note,
          );
          break;
        case MovementType.adjustment:
          await _movementService.recordAdjustment(
            productId: product.id,
            newQuantity: quantity,
            note: note,
          );
          break;
      }

      selectedProduct.value = null;
      await _refreshAfterChange();
      return true;
    } catch (error) {
      formError.value = _readError(error);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _refreshAfterChange() async {
    await loadData();

    if (Get.isRegistered<ProductController>()) {
      await Get.find<ProductController>().loadProducts();
    }

    if (Get.isRegistered<DashboardController>()) {
      await Get.find<DashboardController>().loadDashboard();
    }
  }

  String _readError(Object error) {
    final message = error
        .toString()
        .replaceAll('Exception: ', '')
        .replaceAll('Bad state: ', '')
        .replaceAll('Invalid argument(s): ', '');

    final lowered = message.toLowerCase();
    if (lowered.contains('assertion failed') ||
        lowered.contains('package:flutter/') ||
        lowered.contains('snack_bar.dart')) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }
}
