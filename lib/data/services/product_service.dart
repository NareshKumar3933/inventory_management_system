import 'package:uuid/uuid.dart';

import '../models/product_model.dart';
import 'database_service.dart';

class ProductService {
  ProductService._();

  static final ProductService instance = ProductService._();

  final DatabaseService _databaseService = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  List<ProductModel> getAllProducts({bool includeInactive = false}) {
    final products = _databaseService.productBox.values.where((product) {
      return includeInactive ? true : product.isActive;
    }).toList();

    products.sort((a, b) {
      final dateCompare = b.createdAt.compareTo(a.createdAt);
      if (dateCompare != 0) return dateCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return products;
  }

  ProductModel? getProductById(String id) {
    return _databaseService.productBox.get(id);
  }

  List<ProductModel> getLowStockProducts() {
    final lowStock = getAllProducts().where((item) => item.isLowStock).toList();
    lowStock.sort((a, b) => a.quantity.compareTo(b.quantity));
    return lowStock;
  }

  int getTotalProductCount() => getAllProducts().length;

  int getTotalStockQuantity() {
    return getAllProducts().fold(0, (sum, item) => sum + item.quantity);
  }

  List<String> getCategories() {
    final categories = getAllProducts(includeInactive: true)
        .map((item) => item.category)
        .toSet()
        .toList();
    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  Future<ProductModel> createProduct({
    required String name,
    required String sku,
    required String category,
    int quantity = 0,
    required int minimumLevel,
    double price = 0,
    String imagePath = '',
  }) async {
    final normalizedSku = _normalizeSku(sku);

    if (isSkuTaken(normalizedSku)) {
      throw ArgumentError('SKU "$normalizedSku" already exists.');
    }
    if (quantity < 0) {
      throw ArgumentError('Initial quantity cannot be negative.');
    }
    if (minimumLevel < 0) {
      throw ArgumentError('Minimum level cannot be negative.');
    }

    final now = DateTime.now();

    final product = ProductModel(
      id: _uuid.v4(),
      name: name.trim(),
      sku: normalizedSku,
      category: category.trim(),
      quantity: quantity,
      minimumLevel: minimumLevel,
      price: price,
      imagePath: imagePath.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _databaseService.productBox.put(product.id, product);
    return product;
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String sku,
    required String category,
    required int minimumLevel,
    double price = 0,
    String imagePath = '',
  }) async {
    final existingProduct = getProductById(id);
    if (existingProduct == null) {
      throw ArgumentError('Product not found.');
    }

    final normalizedSku = _normalizeSku(sku);
    if (isSkuTaken(normalizedSku, excludeId: id)) {
      throw ArgumentError('SKU "$normalizedSku" already exists.');
    }

    final updatedProduct = existingProduct.copyWith(
      name: name.trim(),
      sku: normalizedSku,
      category: category.trim(),
      minimumLevel: minimumLevel,
      price: price,
      imagePath: imagePath.trim(),
      updatedAt: DateTime.now(),
    );

    await _databaseService.productBox.put(id, updatedProduct);
  }

  Future<void> updateProductQuantity({
    required String id,
    required int newQuantity,
  }) async {
    if (newQuantity < 0) {
      throw StateError('Stock cannot be negative.');
    }

    final existingProduct = getProductById(id);
    if (existingProduct == null) {
      throw ArgumentError('Product not found.');
    }

    final updatedProduct = existingProduct.copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );

    await _databaseService.productBox.put(id, updatedProduct);
  }

  Future<void> deactivateProduct(String id) async {
    final existingProduct = getProductById(id);
    if (existingProduct == null) return;

    final updatedProduct = existingProduct.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );

    await _databaseService.productBox.put(id, updatedProduct);
  }

  Future<void> reactivateProduct(String id) async {
    final existingProduct = getProductById(id);
    if (existingProduct == null) return;

    final updatedProduct = existingProduct.copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );

    await _databaseService.productBox.put(id, updatedProduct);
  }

  Future<void> deleteProduct(String id) async {
    await _databaseService.productBox.delete(id);
  }

  bool isSkuTaken(String sku, {String? excludeId}) {
    final normalizedSku = _normalizeSku(sku);

    return _databaseService.productBox.values.any((product) {
      return product.sku == normalizedSku &&
          (excludeId == null || product.id != excludeId);
    });
  }

  String _normalizeSku(String sku) {
    return sku.trim().toUpperCase();
  }
}
