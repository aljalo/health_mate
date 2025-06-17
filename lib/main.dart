import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/blood_pressure.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(BloodPressureAdapter());
  await Hive.openBox<BloodPressure>('bloodBox');

  runApp(
    EasyLocalization(
      supportedLocales: [
  Locale('en'),
  Locale('ar'),
  Locale('tr'),
  Locale('de'),
  Locale('ru'),
],

      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: HealthMate(),
    ),
  );
}

class HealthMate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: tr('app_title'),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}
