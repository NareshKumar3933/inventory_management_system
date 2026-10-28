import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../models/movement_model.dart';
import '../models/product_model.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Box<ProductModel> get productBox =>
      Hive.box<ProductModel>(AppConstants.productBox);

  Box<MovementModel> get movementBox =>
      Hive.box<MovementModel>(AppConstants.movementBox);

  Box<dynamic> get settingsBox => Hive.box<dynamic>(AppConstants.settingsBox);

  bool get isFirstRun =>
      settingsBox.get(AppConstants.firstRunKey, defaultValue: true) as bool;

  Future<void> markFirstRunDone() async {
    await settingsBox.put(AppConstants.firstRunKey, false);
  }

  static Future<void> openBoxes() async {
    if (!Hive.isAdapterRegistered(AppConstants.productTypeId)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.movementTypeId)) {
      Hive.registerAdapter(MovementModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.movementTypeEnumId)) {
      Hive.registerAdapter(MovementTypeAdapter());
    }

    await Future.wait([
      Hive.openBox<ProductModel>(AppConstants.productBox),
      Hive.openBox<MovementModel>(AppConstants.movementBox),
      Hive.openBox<dynamic>(AppConstants.settingsBox),
    ]);
  }
}
