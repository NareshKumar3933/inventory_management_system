import 'package:get/get.dart';

import '../features/dashboard/controller/dashboard_controller.dart';
import '../features/export/export_controller.dart';
import '../features/movements/controller/movement_controller.dart';
import '../features/products/controller/product_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
  }
}

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
  }
}

class MovementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovementController>(() => MovementController(), fenix: true);
  }
}

class ExportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExportController>(() => ExportController(), fenix: true);
  }
}
