import 'package:csv/csv.dart';

import '../models/movement_model.dart';
import '../models/product_model.dart';
import 'export_service_web.dart' if (dart.library.io) 'export_service_io.dart';
import 'movement_service.dart';
import 'product_service.dart';

class ExportService {
  ExportService._();

  static final ExportService instance = ExportService._();

  Future<String> exportProducts() async {
    final products = ProductService.instance.getAllProducts();
    final rows = <List<dynamic>>[
      ['name', 'sku', 'category', 'quantity', 'minimumLevel', 'price'],
      ...products.map(
        (product) => [
          product.name,
          product.sku,
          product.category,
          product.quantity,
          product.minimumLevel,
          product.price.toStringAsFixed(2),
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final filename = 'products_${_timestamp()}.csv';
    return saveCsvFile(csv, filename);
  }

  Future<String> exportMovements() async {
    final movements = MovementService.instance.getAllMovements();
    final rows = <List<dynamic>>[
      ['productName', 'type', 'quantity', 'date', 'note'],
      ...movements.map(
        (movement) => [
          movement.productName,
          movement.type.code,
          movement.quantity,
          movement.date.toIso8601String(),
          movement.note,
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final filename = 'movements_${_timestamp()}.csv';
    return saveCsvFile(csv, filename);
  }

  String _timestamp() {
    final now = DateTime.now();
    return '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
  }
}
