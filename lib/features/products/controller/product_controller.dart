import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../movements/controller/movement_controller.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService.instance;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isActionProcessing = false.obs;
  final RxString formError = ''.obs;

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxList<String> categories = <String>[].obs;
  final List<String> statusFilters = const ['Active', 'Inactive', 'All'];

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedStatus = 'Active'.obs;
  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();

  @override
  void onInit() {
    super.onInit();
    loadProducts();

    ever(searchQuery, (_) => _applyFilters());
    ever(selectedCategory, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
  }

  Future<void> loadProducts() async {
    isLoading.value = true;

    final result = _productService.getAllProducts(includeInactive: true);
    products.assignAll(result);

    final categoryValues = ['All', ..._productService.getCategories()];
    categories.assignAll(categoryValues);

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }

    _applyFilters();

    isLoading.value = false;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  void setSelectedProduct(ProductModel? product) {
    selectedProduct.value = product;
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  bool isSkuTaken(String sku, {String? excludeId}) {
    return _productService.isSkuTaken(sku, excludeId: excludeId);
  }

  Future<bool> createProduct({
    required String name,
    required String sku,
    required String category,
    required int quantity,
    required int minimumLevel,
    required double price,
    required String imagePath,
  }) async {
    formError.value = '';
    isSubmitting.value = true;

    try {
      await _productService.createProduct(
        name: name,
        sku: sku,
        category: category,
        quantity: quantity,
        minimumLevel: minimumLevel,
        price: price,
        imagePath: imagePath,
      );

      await _refreshAfterChange();
      return true;
    } catch (error) {
      formError.value = _readError(error);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateProduct({
    required String id,
    required String name,
    required String sku,
    required String category,
    required int minimumLevel,
    required double price,
    required String imagePath,
  }) async {
    formError.value = '';
    isSubmitting.value = true;

    try {
      await _productService.updateProduct(
        id: id,
        name: name,
        sku: sku,
        category: category,
        minimumLevel: minimumLevel,
        price: price,
        imagePath: imagePath,
      );

      await _refreshAfterChange();
      return true;
    } catch (error) {
      formError.value = _readError(error);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deactivateProduct(String productId) async {
    await _productService.deactivateProduct(productId);
    await _refreshAfterChange();
    _showInfo('Product deactivated.', type: AppSnackbarType.warning);
  }

  Future<void> reactivateProduct(String productId) async {
    await _productService.reactivateProduct(productId);
    await _refreshAfterChange();
    _showInfo('Product reactivated.', type: AppSnackbarType.success);
  }

  Future<void> deleteProduct(String productId) async {
    isActionProcessing.value = true;

    try {
      await _productService.deleteProduct(productId);
      await _refreshAfterChange();
      _showInfo('Product deleted permanently.');
    } catch (error) {
      _showInfo(_readError(error), type: AppSnackbarType.error);
    } finally {
      isActionProcessing.value = false;
    }
  }

  void _applyFilters() {
    var result = products.toList();

    if (selectedStatus.value == 'Active') {
      result = result.where((item) => item.isActive).toList();
    } else if (selectedStatus.value == 'Inactive') {
      result = result.where((item) => !item.isActive).toList();
    }

    if (selectedCategory.value != 'All') {
      result = result
          .where((item) => item.category == selectedCategory.value)
          .toList();
    }

    final normalizedQuery = searchQuery.value.trim().toLowerCase();
    if (normalizedQuery.isNotEmpty) {
      result = result.where((item) {
        return item.name.toLowerCase().contains(normalizedQuery) ||
            item.sku.toLowerCase().contains(normalizedQuery) ||
            item.category.toLowerCase().contains(normalizedQuery);
      }).toList();
    }

    filteredProducts.assignAll(result);
  }

  Future<void> _refreshAfterChange() async {
    await loadProducts();

    if (Get.isRegistered<MovementController>()) {
      await Get.find<MovementController>().loadData();
    }

    if (Get.isRegistered<DashboardController>()) {
      await Get.find<DashboardController>().loadDashboard();
    }
  }

  String _readError(Object error) {
    return error
        .toString()
        .replaceAll('Exception: ', '')
        .replaceAll('Invalid argument(s): ', '');
  }

  void _showInfo(String message,
      {AppSnackbarType type = AppSnackbarType.info}) {
    AppSnackbar.show(
      title: 'Inventory',
      message: message,
      type: type,
    );
  }
}
