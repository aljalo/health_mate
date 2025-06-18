import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/blood_sugar.dart';

class BloodSugarScreen extends StatefulWidget {
  const BloodSugarScreen({super.key});

  @override
  _BloodSugarScreenState createState() => _BloodSugarScreenState();
}

class _BloodSugarScreenState extends State<BloodSugarScreen> {
  late Box<BloodSugar> sugarBox;

  @override
  void initState() {
    super.initState();
    sugarBox = Hive.box<BloodSugar>('sugarBox');
  }

  @override
  Widget build(BuildContext context) {
    final lastEntry = sugarBox.values.isNotEmpty ? sugarBox.values.last : null;

    return Scaffold(
      appBar: AppBar(title: Text('blood_sugar.title'.tr())),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('blood_sugar.last_reading'.tr()),
                subtitle: lastEntry != null
                    ? Text(
                        '${lastEntry.sugarLevel} mg/dL\n${lastEntry.date.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 18.sp),
                      )
                    : Text('common.no_data_yet'.tr()),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: Icon(Icons.add),
              label: Text('blood_sugar.add_new_reading'.tr()),
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
    final sugarController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'blood_sugar.enter_blood_sugar'.tr(),
          style: TextStyle(fontSize: 20.sp),
        ),
        content: TextField(
          controller: sugarController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'blood_sugar.title'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final sugarLevel = int.tryParse(sugarController.text);
              if (sugarLevel != null) {
                final entry = BloodSugar(
                  sugarLevel: sugarLevel,
                  date: DateTime.now(),
                );
                sugarBox.add(entry);
                setState(() {}); // refresh UI
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
