import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/blood_pressure.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  late Box<BloodPressure> pressureBox;

  @override
  void initState() {
    super.initState();
    pressureBox = Hive.box<BloodPressure>('pressureBox');
  }

  @override
  Widget build(BuildContext context) {
    final lastEntry = pressureBox.values.isNotEmpty ? pressureBox.values.last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('blood_pressure.title'.tr()),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('blood_pressure.last_reading'.tr()),
                subtitle: lastEntry != null
                    ? Text(
                        '${lastEntry.systolic}/${lastEntry.diastolic} mmHg\n${lastEntry.date.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 18.sp),
                      )
                    : Text('common.no_data_yet'.tr()),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: Text('common.add'.tr()),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('common.enter_value'.tr(), style: TextStyle(fontSize: 20.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'blood_pressure.Systolic (mmHg)'),
            ),
            TextField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'blood_pressure.Diastolic (mmHg)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final systolic = int.tryParse(systolicController.text);
              final diastolic = int.tryParse(diastolicController.text);
              if (systolic != null && diastolic != null) {
                final entry = BloodPressure(
                  systolic: systolic,
                  diastolic: diastolic,
                  date: DateTime.now(),
                );
                pressureBox.add(entry);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
  }
}
