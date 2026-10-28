import '../models/movement_model.dart';

import 'database_service.dart';
import 'movement_service.dart';
import 'product_service.dart';

class DummyDataService {
  DummyDataService._();

  static final DummyDataService instance = DummyDataService._();

  final DatabaseService _databaseService = DatabaseService.instance;
  final ProductService _productService = ProductService.instance;
  final MovementService _movementService = MovementService.instance;

  Future<void> seedIfFirstRun() async {
    if (!_databaseService.isFirstRun) return;

    await _seedProducts();
    await _seedMovements();
    await _databaseService.markFirstRunDone();
  }

  Future<void> _seedProducts() async {
    for (final seed in _productSeeds) {
      try {
        await _productService.createProduct(
          name: seed.name,
          sku: seed.sku,
          category: seed.category,
          quantity: seed.quantity,
          minimumLevel: seed.minimumLevel,
          price: seed.price,
        );
      } catch (_) {
        // Keep seeding resilient.
      }
    }
  }

  Future<void> _seedMovements() async {
    final products = _productService.getAllProducts();
    if (products.length < 12) return;

    final pairs = <({int index, MovementType type, int qty, String note})>[
      (
        index: 0,
        type: MovementType.inward,
        qty: 16,
        note: 'Initial supplier lot'
      ),
      (
        index: 1,
        type: MovementType.outward,
        qty: 4,
        note: 'Retail order IM-1001'
      ),
      (
        index: 2,
        type: MovementType.inward,
        qty: 20,
        note: 'Warehouse transfer'
      ),
      (
        index: 3,
        type: MovementType.adjustment,
        qty: 9,
        note: 'Physical audit correction'
      ),
      (index: 4, type: MovementType.outward, qty: 3, note: 'Sample issue'),
      (index: 5, type: MovementType.inward, qty: 10, note: 'Urgent restock'),
      (index: 6, type: MovementType.outward, qty: 6, note: 'Customer dispatch'),
      (
        index: 7,
        type: MovementType.adjustment,
        qty: 2,
        note: 'Damage write-off'
      ),
      (index: 8, type: MovementType.inward, qty: 7, note: 'Returned stock'),
      (
        index: 9,
        type: MovementType.outward,
        qty: 5,
        note: 'Project allocation'
      ),
      (index: 10, type: MovementType.inward, qty: 14, note: 'Monthly purchase'),
      (
        index: 11,
        type: MovementType.outward,
        qty: 2,
        note: 'Replacement issue'
      ),
    ];

    for (final pair in pairs) {
      final product = products[pair.index];

      try {
        switch (pair.type) {
          case MovementType.inward:
            await _movementService.recordStockIn(
              productId: product.id,
              quantity: pair.qty,
              note: pair.note,
            );
            break;
          case MovementType.outward:
            final qty =
                pair.qty > product.quantity ? product.quantity : pair.qty;
            if (qty > 0) {
              await _movementService.recordStockOut(
                productId: product.id,
                quantity: qty,
                note: pair.note,
              );
            }
            break;
          case MovementType.adjustment:
            await _movementService.recordAdjustment(
              productId: product.id,
              newQuantity: pair.qty,
              note: pair.note,
            );
            break;
        }
      } catch (_) {
        // Keep seeding resilient.
      }
    }
  }
}

class _ProductSeed {
  const _ProductSeed({
    required this.name,
    required this.sku,
    required this.category,
    required this.quantity,
    required this.minimumLevel,
    required this.price,
  });

  final String name;
  final String sku;
  final String category;
  final int quantity;
  final int minimumLevel;
  final double price;
}

const List<_ProductSeed> _productSeeds = [
  _ProductSeed(
      name: 'Dell Latitude 5440',
      sku: 'ELEC-001',
      category: 'Electronics',
      quantity: 12,
      minimumLevel: 5,
      price: 1099),
  _ProductSeed(
      name: 'Lenovo ThinkPad E14',
      sku: 'ELEC-002',
      category: 'Electronics',
      quantity: 9,
      minimumLevel: 4,
      price: 949),
  _ProductSeed(
      name: 'Logitech MX Keys',
      sku: 'ELEC-003',
      category: 'Electronics',
      quantity: 26,
      minimumLevel: 10,
      price: 119),
  _ProductSeed(
      name: 'USB-C Dock Station',
      sku: 'ELEC-004',
      category: 'Electronics',
      quantity: 4,
      minimumLevel: 6,
      price: 89),
  _ProductSeed(
      name: 'Samsung 27-inch Monitor',
      sku: 'ELEC-005',
      category: 'Electronics',
      quantity: 7,
      minimumLevel: 3,
      price: 249),
  _ProductSeed(
      name: 'Razer Basilisk Mouse',
      sku: 'ELEC-006',
      category: 'Electronics',
      quantity: 31,
      minimumLevel: 12,
      price: 69),
  _ProductSeed(
      name: 'HP LaserJet Toner',
      sku: 'OFF-001',
      category: 'Office Supplies',
      quantity: 15,
      minimumLevel: 6,
      price: 58),
  _ProductSeed(
      name: 'A4 Printer Paper Box',
      sku: 'OFF-002',
      category: 'Office Supplies',
      quantity: 120,
      minimumLevel: 25,
      price: 34),
  _ProductSeed(
      name: 'Stapler Set Heavy Duty',
      sku: 'OFF-003',
      category: 'Office Supplies',
      quantity: 5,
      minimumLevel: 5,
      price: 14),
  _ProductSeed(
      name: 'Dry Erase Marker Pack',
      sku: 'OFF-004',
      category: 'Office Supplies',
      quantity: 40,
      minimumLevel: 12,
      price: 9),
  _ProductSeed(
      name: 'Sticky Notes Assorted',
      sku: 'OFF-005',
      category: 'Office Supplies',
      quantity: 86,
      minimumLevel: 20,
      price: 8),
  _ProductSeed(
      name: 'Binder Clips 100-Pack',
      sku: 'OFF-006',
      category: 'Office Supplies',
      quantity: 18,
      minimumLevel: 8,
      price: 6),
  _ProductSeed(
      name: 'Ergonomic Office Chair',
      sku: 'FURN-001',
      category: 'Furniture',
      quantity: 6,
      minimumLevel: 3,
      price: 279),
  _ProductSeed(
      name: 'Adjustable Standing Desk',
      sku: 'FURN-002',
      category: 'Furniture',
      quantity: 3,
      minimumLevel: 3,
      price: 429),
  _ProductSeed(
      name: 'Metal Storage Cabinet',
      sku: 'FURN-003',
      category: 'Furniture',
      quantity: 2,
      minimumLevel: 2,
      price: 189),
  _ProductSeed(
      name: 'Meeting Table 6-Seater',
      sku: 'FURN-004',
      category: 'Furniture',
      quantity: 1,
      minimumLevel: 2,
      price: 499),
  _ProductSeed(
      name: 'Cat6 Cable 10m',
      sku: 'NET-001',
      category: 'Networking',
      quantity: 55,
      minimumLevel: 15,
      price: 12),
  _ProductSeed(
      name: 'MikroTik Router',
      sku: 'NET-002',
      category: 'Networking',
      quantity: 5,
      minimumLevel: 3,
      price: 139),
  _ProductSeed(
      name: '24-Port Switch',
      sku: 'NET-003',
      category: 'Networking',
      quantity: 4,
      minimumLevel: 2,
      price: 219),
  _ProductSeed(
      name: 'Access Point WiFi 6',
      sku: 'NET-004',
      category: 'Networking',
      quantity: 8,
      minimumLevel: 4,
      price: 159),
  _ProductSeed(
      name: 'NAS 2-Bay',
      sku: 'STG-001',
      category: 'Storage',
      quantity: 3,
      minimumLevel: 2,
      price: 329),
  _ProductSeed(
      name: '1TB NVMe SSD',
      sku: 'STG-002',
      category: 'Storage',
      quantity: 10,
      minimumLevel: 5,
      price: 109),
  _ProductSeed(
      name: '4TB HDD',
      sku: 'STG-003',
      category: 'Storage',
      quantity: 7,
      minimumLevel: 4,
      price: 119),
  _ProductSeed(
      name: 'USB Drive 128GB',
      sku: 'STG-004',
      category: 'Storage',
      quantity: 44,
      minimumLevel: 15,
      price: 18),
  _ProductSeed(
      name: 'AA Battery 24-Pack',
      sku: 'CONS-001',
      category: 'Consumables',
      quantity: 96,
      minimumLevel: 30,
      price: 15),
  _ProductSeed(
      name: 'Cable Ties 200-Pack',
      sku: 'CONS-002',
      category: 'Consumables',
      quantity: 12,
      minimumLevel: 15,
      price: 7),
  _ProductSeed(
      name: 'Microfiber Cleaning Kit',
      sku: 'CONS-003',
      category: 'Consumables',
      quantity: 9,
      minimumLevel: 10,
      price: 11),
  _ProductSeed(
      name: 'Compressed Air Can',
      sku: 'CONS-004',
      category: 'Consumables',
      quantity: 14,
      minimumLevel: 8,
      price: 13),
  _ProductSeed(
      name: 'Office 365 License',
      sku: 'SOFT-001',
      category: 'Software',
      quantity: 12,
      minimumLevel: 4,
      price: 99),
  _ProductSeed(
      name: 'Adobe CC License',
      sku: 'SOFT-002',
      category: 'Software',
      quantity: 4,
      minimumLevel: 3,
      price: 599),
  _ProductSeed(
      name: 'Endpoint Security License',
      sku: 'SOFT-003',
      category: 'Software',
      quantity: 2,
      minimumLevel: 4,
      price: 41),
  _ProductSeed(
      name: 'VPN Subscription Seat',
      sku: 'SOFT-004',
      category: 'Software',
      quantity: 7,
      minimumLevel: 3,
      price: 79),
  _ProductSeed(
      name: 'Kensington Laptop Lock',
      sku: 'SEC-001',
      category: 'Security',
      quantity: 2,
      minimumLevel: 3,
      price: 25),
  _ProductSeed(
      name: 'CCTV Dome Camera',
      sku: 'SEC-002',
      category: 'Security',
      quantity: 11,
      minimumLevel: 4,
      price: 69),
  _ProductSeed(
      name: 'Fingerprint Access Panel',
      sku: 'SEC-003',
      category: 'Security',
      quantity: 3,
      minimumLevel: 2,
      price: 179),
  _ProductSeed(
      name: 'Surge Protector 8-Port',
      sku: 'SEC-004',
      category: 'Security',
      quantity: 19,
      minimumLevel: 6,
      price: 27),
  _ProductSeed(
      name: 'Barcode Scanner Handheld',
      sku: 'OPS-001',
      category: 'Operations',
      quantity: 8,
      minimumLevel: 4,
      price: 129),
  _ProductSeed(
      name: 'Thermal Label Printer',
      sku: 'OPS-002',
      category: 'Operations',
      quantity: 2,
      minimumLevel: 2,
      price: 239),
  _ProductSeed(
      name: 'Label Roll 1000pcs',
      sku: 'OPS-003',
      category: 'Operations',
      quantity: 70,
      minimumLevel: 20,
      price: 16),
  _ProductSeed(
      name: 'Pallet Jack Manual',
      sku: 'OPS-004',
      category: 'Operations',
      quantity: 1,
      minimumLevel: 1,
      price: 399),
];
