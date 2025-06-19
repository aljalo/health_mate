import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_mate/models/theme_mode_enum.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models/blood_pressure.dart';
import 'models/blood_sugar.dart';
import 'models/medication.dart';

import 'screens/home_screen.dart';
import 'screens/blood_pressure_screen.dart';
import 'screens/blood_sugar_screen.dart';
import 'screens/medications_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(BloodPressureAdapter());
  Hive.registerAdapter(BloodSugarAdapter());
  Hive.registerAdapter(MedicationAdapter());
  Hive.registerAdapter(AppThemeModeAdapter());
  await Hive.openBox('settingsBox');
  await Hive.openBox<BloodPressure>('pressureBox');
  await Hive.openBox<BloodSugar>('sugarBox');
  await Hive.openBox<Medication>('medicationsBox');

// Local Notifications initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late Box settingsBox;
  late AppThemeMode appThemeMode;
@override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settingsBox');
    appThemeMode = settingsBox.get('themeMode', defaultValue: AppThemeMode.system);
    settingsBox.watch(key: 'themeMode').listen((event) {
      setState(() {
        appThemeMode = event.value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: _getThemeMode(), //ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          title: 'HealthMate',

          home: HomeScreen(),
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          routes: {
            '/bloodPressure': (context) => BloodPressureScreen(),
            '/bloodSugar': (context) => BloodSugarScreen(),
            '/medications': (context) => MedicationsScreen(),
          },
        );
      },
    );
  }
  ThemeMode _getThemeMode() {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}

