import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/blood_pressure.dart';
import '../models/blood_sugar.dart';
import '../models/medication.dart';
import 'blood_pressure_screen.dart';
import 'blood_sugar_screen.dart';
import 'medications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<BloodPressure> pressureBox;
  late Box<BloodSugar> sugarBox;
  late Box<Medication> medicationBox;

  @override
  void initState() {
    super.initState();
    pressureBox = Hive.box<BloodPressure>('pressureBox');
    sugarBox = Hive.box<BloodSugar>('sugarBox');
    medicationBox = Hive.box<Medication>('medicationsBox');
  }

  @override
  Widget build(BuildContext context) {
    final lastPressure = pressureBox.values.isNotEmpty
        ? pressureBox.values.last
        : null;
    final lastSugar = sugarBox.values.isNotEmpty ? sugarBox.values.last : null;
    final meds = medicationBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr()),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: DropdownButton<Locale>(
              underline: SizedBox(),
              icon: Icon(
                Icons.language,
                color: Theme.of(context).iconTheme.color,
              ),
              onChanged: (Locale? locale) {
                if (locale != null) {
                  context.setLocale(locale);
                }
              },
              items: [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
                DropdownMenuItem(value: Locale('gr'), child: Text('Deutsch')),
                DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
                DropdownMenuItem(value: Locale('tr'), child: Text('Türkçe')),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildCard(
              title: 'blood_pressure.last_reading'.tr(),
              subtitle: lastPressure != null
                  ? '${lastPressure.systolic}/${lastPressure.diastolic} mmHg\n${lastPressure.date.toLocal().toString().split(' ')[0]}'
                  : 'common.no_data_yet'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BloodPressureScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            _buildCard(
              title: 'blood_sugar.last_reading'.tr(),
              subtitle: lastSugar != null
                  ? '${lastSugar.sugarLevel} mg/dL\n${lastSugar.date.toLocal().toString().split(' ')[0]}'
                  : 'common.no_data_yet'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BloodSugarScreen()),
                );
              },
            ),
            SizedBox(height: 16.h),
            _buildCard(
              title: 'medications.title'.tr(),
              subtitle: meds.isNotEmpty
                  ? '${meds.length} medications\nNext: ${meds[0].name} @ ${meds[0].reminderTime}'
                  : 'common.no_data_yet'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicationsScreen()),
                );
              },
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () async {
                await pressureBox.clear();
                await sugarBox.clear();
                await medicationBox.clear();
                setState(() {}); // refresh UI
              },
              icon: Icon(Icons.refresh),
              label: Text('common.reset'.tr()),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18.sp)),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Text(subtitle, style: TextStyle(fontSize: 16.sp)),
        ),
        trailing: IconButton(icon: Icon(Icons.arrow_forward), onPressed: onTap),
      ),
    );
  }
}
