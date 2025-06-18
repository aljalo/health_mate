import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_mate/utils/date_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medication.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  late Box<Medication> medicationBox;

  @override
  void initState() {
    super.initState();
    medicationBox = Hive.box<Medication>('medicationsBox');
  }

  // DateTime _timeOfDayToDateTime(TimeOfDay tod) {
  //   final now = DateTime.now();
  //   return DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  // }

  // String _formatTime(DateTime dt) {
  //   final hour = dt.hour > 12
  //       ? dt.hour - 12
  //       : dt.hour == 0
  //       ? 12
  //       : dt.hour;
  //   final minute = dt.minute.toString().padLeft(2, '0');
  //   final period = dt.hour >= 12 ? 'PM' : 'AM';
  //   return '$hour:$minute $period';
  // }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    TimeOfDay? reminderTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('medications.add_medication'.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'medications.medication_name'.tr(),
                      ),
                    ),
                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        labelText: 'medications.dosage'.tr(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setStateDialog(() {
                            reminderTime = time;
                          });
                        }
                      },
                      child: Text(
                        reminderTime == null
                            ? 'medications.select_time'.tr()
                            : 'medications.reminder_time: ${reminderTime!.format(context)}'
                                  .tr(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('common.cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        dosageController.text.isNotEmpty &&
                        reminderTime != null) {
                      final medication = Medication(
                        name: nameController.text,
                        dosage: dosageController.text,
                        //reminderTime: _timeOfDayToDateTime(reminderTime!),
                        reminderTime: DateUtilsHelper.timeOfDayToDateTime(
                          reminderTime!,
                        ),
                      );
                      medicationBox.add(medication);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('common.save'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('medications.title'.tr())),
      body: ValueListenableBuilder(
        valueListenable: medicationBox.listenable(),
        builder: (context, Box<Medication> box, _) {
          final meds = box.values.toList();
          if (meds.isEmpty) {
            return Center(
              child: Text('medications.no_medications_added_yet'.tr()),
            );
          }
          return ListView.builder(
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              return ListTile(
                title: Text(med.name),
                subtitle: Text(
                  'medications.dosage: ${med.dosage}\nmedications.reminder_time: ${DateUtilsHelper.formatTime(med.reminderTime)}'
                      .tr(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicationDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
