import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 2)
class Medication extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String dosage;

  @HiveField(2)
  DateTime reminderTime;

  Medication({
    required this.name,
    required this.dosage,
    required this.reminderTime,
  });
}
