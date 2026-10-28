import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'product_model.g.dart';

@HiveType(typeId: AppConstants.productTypeId)
class ProductModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String sku;

  @HiveField(3)
  String category;

  @HiveField(4)
  int quantity;

  @HiveField(5)
  int minimumLevel;

  @HiveField(6)
  double price;

  @HiveField(7)
  String imagePath;

  @HiveField(8)
  bool isActive;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    this.quantity = 0,
    required this.minimumLevel,
    this.price = 0,
    this.imagePath = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => quantity <= minimumLevel;

  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    int? quantity,
    int? minimumLevel,
    double? price,
    String? imagePath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
