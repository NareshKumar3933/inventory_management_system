import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'movement_model.g.dart';

@HiveType(typeId: AppConstants.movementTypeEnumId)
enum MovementType {
  @HiveField(0)
  inward,
  @HiveField(1)
  outward,
  @HiveField(2)
  adjustment,
}

extension MovementTypeX on MovementType {
  String get code {
    switch (this) {
      case MovementType.inward:
        return 'IN';
      case MovementType.outward:
        return 'OUT';
      case MovementType.adjustment:
        return 'ADJUSTMENT';
    }
  }

  String get label {
    switch (this) {
      case MovementType.inward:
        return 'Stock In';
      case MovementType.outward:
        return 'Stock Out';
      case MovementType.adjustment:
        return 'Adjustment';
    }
  }
}

@HiveType(typeId: AppConstants.movementTypeId)
class MovementModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productId;

  @HiveField(2)
  MovementType type;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String note;

  @HiveField(6)
  String productName;

  MovementModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
    this.note = '',
    this.productName = '',
  });
}
