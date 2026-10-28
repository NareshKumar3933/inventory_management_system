// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovementModelAdapter extends TypeAdapter<MovementModel> {
  @override
  final int typeId = 1;

  @override
  MovementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovementModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      type: fields[2] as MovementType,
      quantity: fields[3] as int,
      date: fields[4] as DateTime,
      note: fields[5] as String,
      productName: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MovementModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.productName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MovementTypeAdapter extends TypeAdapter<MovementType> {
  @override
  final int typeId = 2;

  @override
  MovementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MovementType.inward;
      case 1:
        return MovementType.outward;
      case 2:
        return MovementType.adjustment;
      default:
        return MovementType.inward;
    }
  }

  @override
  void write(BinaryWriter writer, MovementType obj) {
    switch (obj) {
      case MovementType.inward:
        writer.writeByte(0);
        break;
      case MovementType.outward:
        writer.writeByte(1);
        break;
      case MovementType.adjustment:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
