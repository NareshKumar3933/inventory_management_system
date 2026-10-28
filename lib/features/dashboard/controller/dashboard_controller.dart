import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/movement_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/movement_service.dart';
import '../../../data/services/product_service.dart';

class DashboardController extends GetxController {
  final ProductService _productService = ProductService.instance;
  final MovementService _movementService = MovementService.instance;

  final RxBool isLoading = false.obs;

  final RxInt totalProducts = 0.obs;
  final RxInt totalStock = 0.obs;
  final RxList<ProductModel> lowStockProducts = <ProductModel>[].obs;
  final RxList<MovementModel> recentMovements = <MovementModel>[].obs;
  final RxMap<String, int> categoryStock = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;

    totalProducts.value = _productService.getTotalProductCount();
    totalStock.value = _productService.getTotalStockQuantity();
    lowStockProducts.assignAll(_productService.getLowStockProducts());
    recentMovements.assignAll(
      _movementService.getRecentMovements(limit: AppConstants.recentMovementsCount),
    );

    final stockMap = <String, int>{};
    for (final product in _productService.getAllProducts()) {
      stockMap[product.category] = (stockMap[product.category] ?? 0) + product.quantity;
    }
    categoryStock.assignAll(stockMap);

    isLoading.value = false;
  }
}
