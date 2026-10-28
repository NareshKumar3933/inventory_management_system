import 'package:uuid/uuid.dart';

import '../models/movement_model.dart';
import '../models/product_model.dart';
import 'database_service.dart';
import 'product_service.dart';

class MovementService {
  MovementService._();

  static final MovementService instance = MovementService._();

  final DatabaseService _databaseService = DatabaseService.instance;
  final ProductService _productService = ProductService.instance;
  final Uuid _uuid = const Uuid();

  List<MovementModel> getAllMovements() {
    final movements = _databaseService.movementBox.values.toList();
    movements.sort((a, b) => b.date.compareTo(a.date));
    return movements;
  }

  List<MovementModel> getRecentMovements({int limit = 10}) {
    return getAllMovements().take(limit).toList();
  }

  List<MovementModel> getMovementsForProduct(String productId) {
    final result = _databaseService.movementBox.values
        .where((movement) => movement.productId == productId)
        .toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  Future<MovementModel> recordStockIn({
    required String productId,
    required int quantity,
    String note = '',
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }

    final product = _getExistingProduct(productId);
    await _productService.updateProductQuantity(
      id: productId,
      newQuantity: product.quantity + quantity,
    );

    return _createMovement(
      product: product,
      type: MovementType.inward,
      quantity: quantity,
      note: note,
    );
  }

  Future<MovementModel> recordStockOut({
    required String productId,
    required int quantity,
    String note = '',
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }

    final product = _getExistingProduct(productId);

    if (quantity > product.quantity) {
      throw StateError(
        'Insufficient stock. Available ${product.quantity}, requested $quantity.',
      );
    }

    await _productService.updateProductQuantity(
      id: productId,
      newQuantity: product.quantity - quantity,
    );

    return _createMovement(
      product: product,
      type: MovementType.outward,
      quantity: quantity,
      note: note,
    );
  }

  Future<MovementModel> recordAdjustment({
    required String productId,
    required int newQuantity,
    String note = '',
  }) async {
    if (newQuantity < 0) {
      throw ArgumentError('Adjusted quantity cannot be negative.');
    }

    final product = _getExistingProduct(productId);

    await _productService.updateProductQuantity(
      id: productId,
      newQuantity: newQuantity,
    );

    return _createMovement(
      product: product,
      type: MovementType.adjustment,
      quantity: newQuantity,
      note: note.isEmpty ? 'Adjusted stock to $newQuantity' : note,
    );
  }

  ProductModel _getExistingProduct(String productId) {
    final product = _productService.getProductById(productId);
    if (product == null) {
      throw ArgumentError('Product not found.');
    }
    return product;
  }

  Future<MovementModel> _createMovement({
    required ProductModel product,
    required MovementType type,
    required int quantity,
    required String note,
  }) async {
    final movement = MovementModel(
      id: _uuid.v4(),
      productId: product.id,
      productName: product.name,
      type: type,
      quantity: quantity,
      date: DateTime.now(),
      note: note.trim(),
    );

    await _databaseService.movementBox.put(movement.id, movement);
    return movement;
  }
}
