import 'package:get/get.dart';

import '../core/constants/route_constants.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/export/export_screen.dart';
import '../features/movements/view/movement_form_screen.dart';
import '../features/movements/view/movement_list_screen.dart';
import '../features/products/view/product_form_screen.dart';
import '../features/products/view/product_list_screen.dart';
import 'app_binding.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductListScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => const ProductFormScreen(isEditing: false),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.editProduct,
      page: () => const ProductFormScreen(isEditing: true),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.movements,
      page: () => const MovementListScreen(),
      binding: MovementBinding(),
    ),
    GetPage(
      name: AppRoutes.addMovement,
      page: () => const MovementFormScreen(),
      binding: MovementBinding(),
    ),
    GetPage(
      name: AppRoutes.export,
      page: () => const ExportScreen(),
      bindings: [ProductBinding(), MovementBinding(), ExportBinding()],
    ),
  ];
}
