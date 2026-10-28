import 'package:get/get.dart';

import '../../core/utils/app_snackbar.dart';
import '../../data/services/export_service.dart';
import '../../data/services/movement_service.dart';
import '../../data/services/product_service.dart';

class ExportController extends GetxController {
  final ExportService _exportService = ExportService.instance;

  final RxBool isExportingProducts = false.obs;
  final RxBool isExportingMovements = false.obs;
  final RxString statusMessage = ''.obs;
  final RxString lastExportPath = ''.obs;

  final RxInt productCount = 0.obs;
  final RxInt movementCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshCounts();
  }

  Future<void> refreshCounts() async {
    productCount.value = ProductService.instance.getTotalProductCount();
    movementCount.value = MovementService.instance.getAllMovements().length;
  }

  Future<void> exportProducts() async {
    isExportingProducts.value = true;
    statusMessage.value = '';

    try {
      final path = await _exportService.exportProducts();
      lastExportPath.value = path;
      statusMessage.value = path.isEmpty
          ? 'Products CSV downloaded successfully.'
          : 'Products CSV saved to $path';

      AppSnackbar.show(
        title: 'Export completed',
        message: statusMessage.value,
        type: AppSnackbarType.success,
      );
    } catch (error) {
      statusMessage.value = 'Export failed: ${error.toString()}';
      AppSnackbar.show(
        title: 'Export failed',
        message: statusMessage.value,
        type: AppSnackbarType.error,
      );
    } finally {
      isExportingProducts.value = false;
    }
  }

  Future<void> exportMovements() async {
    isExportingMovements.value = true;
    statusMessage.value = '';

    try {
      final path = await _exportService.exportMovements();
      lastExportPath.value = path;
      statusMessage.value = path.isEmpty
          ? 'Movements CSV downloaded successfully.'
          : 'Movements CSV saved to $path';

      AppSnackbar.show(
        title: 'Export completed',
        message: statusMessage.value,
        type: AppSnackbarType.success,
      );
    } catch (error) {
      statusMessage.value = 'Export failed: ${error.toString()}';
      AppSnackbar.show(
        title: 'Export failed',
        message: statusMessage.value,
        type: AppSnackbarType.error,
      );
    } finally {
      isExportingMovements.value = false;
    }
  }
}
