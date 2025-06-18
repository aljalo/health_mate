// models/theme_mode_enum.dart

import 'package:hive/hive.dart';

part 'theme_mode_enum.g.dart';

@HiveType(typeId: 1)
enum AppThemeMode {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}
