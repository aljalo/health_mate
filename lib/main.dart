import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(BloodPressureAdapter());
  Hive.registerAdapter(BloodSugarAdapter());
  Hive.registerAdapter(MedicationAdapter());

  await Hive.openBox<BloodPressure>('pressureBox');
  await Hive.openBox<BloodSugar>('sugarBox');
  await Hive.openBox<Medication>('medicationsBox');

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          //themeMode: ThemeMode.system,
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
}



// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:easy_localization/easy_localization.dart';

// import 'models/blood_pressure.dart';
// import 'models/blood_sugar.dart';
// import 'models/medication.dart';

// import 'screens/home_screen.dart';
// import 'screens/blood_pressure_screen.dart';
// import 'screens/blood_sugar_screen.dart';
// import 'screens/medications_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized();
//   await Hive.initFlutter();

//   Hive.registerAdapter(BloodPressureAdapter());
//   Hive.registerAdapter(BloodSugarAdapter());
//   Hive.registerAdapter(MedicationAdapter());

//   await Hive.openBox<BloodPressure>('pressureBox');
//   await Hive.openBox<BloodSugar>('sugarBox');
//   await Hive.openBox<Medication>('medicationsBox');

//   runApp(
//     EasyLocalization(
//       supportedLocales: [Locale('en'), Locale('tr')],
//       path: 'assets/translations',
//       fallbackLocale: Locale('en'),
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: Size(360, 690),
//       builder: (context, child) {
//         return MaterialApp(
//           title: 'HealthMate',
//           theme: ThemeData(primarySwatch: Colors.teal),
//           home: HomeScreen(),
//           locale: context.locale,
//           supportedLocales: context.supportedLocales,
//           localizationsDelegates: context.localizationDelegates,
//           routes: {
//             '/bloodPressure': (context) => BloodPressureScreen(),
//             '/bloodSugar': (context) => BloodSugarScreen(),
//             '/medications': (context) => MedicationsScreen(),
//           },
//         );
//       },
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:health_mate/models/blood_sugar.dart';
// import 'package:health_mate/models/medication.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'models/blood_pressure.dart';
// import 'screens/home_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await EasyLocalization.ensureInitialized();
//   await Hive.initFlutter();

//   Hive.registerAdapter(BloodPressureAdapter());
//   Hive.registerAdapter(BloodSugarAdapter());
//   Hive.registerAdapter(MedicationAdapter());

//   await Hive.openBox<Medication>('medicationsBox');
//   await Hive.openBox<BloodPressure>('pressureBox');
//   await Hive.openBox<BloodSugar>('sugarBox');

//   runApp(
//     EasyLocalization(
//       supportedLocales: [
//         Locale('en'),
//         Locale('ar'),
//         Locale('tr'),
//         Locale('de'),
//         Locale('ru'),
//       ],

//       path: 'assets/translations',
//       fallbackLocale: Locale('en'),
//       child: HealthMate(),
//     ),
//   );
// }

// class HealthMate extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: Size(360, 690),
//       minTextAdapt: true,
//       builder: (context, child) {
//         return MaterialApp(
//           theme: ThemeData.light(),
//           darkTheme: ThemeData.dark(),
//           themeMode: ThemeMode.system,
//           debugShowCheckedModeBanner: false,
//           title: tr('app_title'),
//           localizationsDelegates: context.localizationDelegates,
//           supportedLocales: context.supportedLocales,
//           locale: context.locale,
//           //theme: ThemeData(primarySwatch: Colors.teal),
//           home: HomeScreen(),
//         );
//       },
//     );
//   }
// }
