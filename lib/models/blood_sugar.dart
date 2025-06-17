import 'package:hive/hive.dart';

part 'blood_sugar.g.dart';

@HiveType(typeId: 1)
class BloodSugar extends HiveObject {
  @HiveField(0)
  final int sugarLevel;

  @HiveField(1)
  final DateTime date;

  BloodSugar({
    required this.sugarLevel,
    required this.date,
  });
}
