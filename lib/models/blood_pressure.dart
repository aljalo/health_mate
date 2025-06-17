import 'package:hive/hive.dart';

part 'blood_pressure.g.dart';

@HiveType(typeId: 0)
class BloodPressure extends HiveObject {
  @HiveField(0)
  final int systolic;

  @HiveField(1)
  final int diastolic;

  @HiveField(2)
  final DateTime date;

  BloodPressure({
    required this.systolic,
    required this.diastolic,
    required this.date,
  });
}
