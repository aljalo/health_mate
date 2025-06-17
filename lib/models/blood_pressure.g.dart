// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_pressure.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloodPressureAdapter extends TypeAdapter<BloodPressure> {
  @override
  final int typeId = 0;

  @override
  BloodPressure read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BloodPressure(
      systolic: fields[0] as int,
      diastolic: fields[1] as int,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BloodPressure obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.systolic)
      ..writeByte(1)
      ..write(obj.diastolic)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodPressureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
