import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../models/medication.dart';

class MedicationsScreen extends StatefulWidget {
  @override
  _MedicationsScreenState createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  late Box<Medication> medicationBox;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    medicationBox = Hive.box<Medication>('medicationsBox');
    _requestNotificationPermission();
    _initNotifications();
  }

  Future<void> _requestNotificationPermission() async {
    // طلب إذن Notifications
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    // طلب إذن SCHEDULE_EXACT_ALARM (مطلوب في Android 13+)
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (!exactAlarmStatus.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    tz.initializeTimeZones();
  }

  Future<void> _scheduleNotification(Medication medication, int id) async {
    final androidDetails = AndroidNotificationDetails(
      'med_channel',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   id,
    //   'Time to take your medication',
    //   '${medication.name} - ${medication.dosage}',
    //   _nextInstanceOfTime(medication.reminderTime),
    //   details,
    //   androidAllowWhileIdle: true,
    //   matchDateTimeComponents: DateTimeComponents.time,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    // );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Time to take your medication',
      '${medication.name} - ${medication.dosage}',
      _nextInstanceOfTime(medication.reminderTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      //uiLocalNotificationDateInterpretation:
      //UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime reminderTime) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    return scheduledDate;
  }

  void _showAddOrEditDialog({Medication? medication, int? index}) {
    final nameController = TextEditingController(text: medication?.name ?? '');
    final dosageController = TextEditingController(
      text: medication?.dosage ?? '',
    );
    TimeOfDay? reminderTime = medication != null
        ? TimeOfDay(
            hour: medication.reminderTime.hour,
            minute: medication.reminderTime.minute,
          )
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                medication == null ? 'Add Medication' : 'Edit Medication',
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Medication Name'),
                    ),
                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(labelText: 'Dosage'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: reminderTime ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setStateDialog(() {
                            reminderTime = pickedTime;
                          });
                        }
                      },
                      child: Text(
                        reminderTime == null
                            ? 'Select Reminder Time'
                            : 'Reminder: ${reminderTime!.format(context)}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        dosageController.text.isNotEmpty &&
                        reminderTime != null) {
                      final reminderDateTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        reminderTime!.hour,
                        reminderTime!.minute,
                      );

                      final newMed = Medication(
                        name: nameController.text,
                        dosage: dosageController.text,
                        reminderTime: reminderDateTime,
                      );

                      if (index == null) {
                        await medicationBox.add(newMed);
                        await _scheduleNotification(
                          newMed,
                          medicationBox.length - 1,
                        );
                      } else {
                        await medicationBox.putAt(index, newMed);
                        await _scheduleNotification(newMed, index);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteMedication(int index) async {
    await flutterLocalNotificationsPlugin.cancel(index);
    await medicationBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medications')),
      body: ValueListenableBuilder(
        valueListenable: medicationBox.listenable(),
        builder: (context, Box<Medication> box, _) {
          final meds = box.values.toList();
          if (meds.isEmpty) {
            return Center(child: Text('No medications added yet.'));
          }
          return ListView.builder(
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              return Card(
                child: ListTile(
                  title: Text(med.name),
                  subtitle: Text(
                    'Dosage: ${med.dosage}\nReminder: ${_formatTime(med.reminderTime)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showAddOrEditDialog(medication: med, index: index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteMedication(index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddOrEditDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}


// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// import '../models/medication.dart';

// class MedicationsScreen extends StatefulWidget {
//   @override
//   _MedicationsScreenState createState() => _MedicationsScreenState();
// }

// class _MedicationsScreenState extends State<MedicationsScreen> {
//   late Box<Medication> medicationBox;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     medicationBox = Hive.box<Medication>('medicationsBox');
//     _requestNotificationPermission();
//     _initNotifications();
//   }

//   Future<void> _requestNotificationPermission() async {
//     final status = await Permission.notification.status;
//     if (!status.isGranted) {
//       await Permission.notification.request();
//     }
//     // طلب إذن SCHEDULE_EXACT_ALARM
//   final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
//   if (!exactAlarmStatus.isGranted) {
//     await Permission.scheduleExactAlarm.request();
//   }
//   }

//   Future<void> _initNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//     tz.initializeTimeZones();
//   }

//   Future<void> _scheduleNotification(Medication medication, int id) async {
//     final androidDetails = AndroidNotificationDetails(
//       'med_channel',
//       'Medication Reminders',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     final details = NotificationDetails(android: androidDetails);

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       'Time to take your medication',
//       '${medication.name} - ${medication.dosage}',
//       _nextInstanceOfTime(medication.reminderTime),
//       details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//   matchDateTimeComponents: DateTimeComponents.time,
//   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

      
//       //androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       //androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       //androidScheduleMode: AndroidScheduleMode.whileIdle,

//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   tz.TZDateTime _nextInstanceOfTime(DateTime reminderTime) {
//     final now = tz.TZDateTime.now(tz.local);
//     var scheduledDate = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       reminderTime.hour,
//       reminderTime.minute,
//     );

//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }

//     return scheduledDate;
//   }

//   void _showAddOrEditDialog({Medication? medication, int? index}) {
//     final nameController = TextEditingController(text: medication?.name ?? '');
//     final dosageController = TextEditingController(
//       text: medication?.dosage ?? '',
//     );
//     TimeOfDay? reminderTime = medication != null
//         ? TimeOfDay(
//             hour: medication.reminderTime.hour,
//             minute: medication.reminderTime.minute,
//           )
//         : null;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             return AlertDialog(
//               title: Text(
//                 medication == null ? 'Add Medication' : 'Edit Medication',
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(labelText: 'Medication Name'),
//                     ),
//                     TextField(
//                       controller: dosageController,
//                       decoration: InputDecoration(labelText: 'Dosage'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () async {
//                         final pickedTime = await showTimePicker(
//                           context: context,
//                           initialTime: reminderTime ?? TimeOfDay.now(),
//                         );
//                         if (pickedTime != null) {
//                           setStateDialog(() {
//                             reminderTime = pickedTime;
//                           });
//                         }
//                       },
//                       child: Text(
//                         reminderTime == null
//                             ? 'Select Reminder Time'
//                             : 'Reminder: ${reminderTime!.format(context)}',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (nameController.text.isNotEmpty &&
//                         dosageController.text.isNotEmpty &&
//                         reminderTime != null) {
//                       final reminderDateTime = DateTime(
//                         DateTime.now().year,
//                         DateTime.now().month,
//                         DateTime.now().day,
//                         reminderTime!.hour,
//                         reminderTime!.minute,
//                       );

//                       final newMed = Medication(
//                         name: nameController.text,
//                         dosage: dosageController.text,
//                         reminderTime: reminderDateTime,
//                       );

//                       if (index == null) {
//                         await medicationBox.add(newMed);
//                         await _scheduleNotification(
//                           newMed,
//                           medicationBox.length - 1,
//                         );
//                       } else {
//                         await medicationBox.putAt(index, newMed);
//                         await _scheduleNotification(newMed, index);
//                       }

//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text('Save'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   void _deleteMedication(int index) async {
//     await flutterLocalNotificationsPlugin.cancel(index);
//     await medicationBox.deleteAt(index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Medications')),
//       body: ValueListenableBuilder(
//         valueListenable: medicationBox.listenable(),
//         builder: (context, Box<Medication> box, _) {
//           final meds = box.values.toList();
//           if (meds.isEmpty) {
//             return Center(child: Text('No medications added yet.'));
//           }
//           return ListView.builder(
//             itemCount: meds.length,
//             itemBuilder: (context, index) {
//               final med = meds[index];
//               return Card(
//                 child: ListTile(
//                   title: Text(med.name),
//                   subtitle: Text(
//                     'Dosage: ${med.dosage}\nReminder: ${_formatTime(med.reminderTime)}',
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () {
//                           _showAddOrEditDialog(medication: med, index: index);
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () {
//                           _deleteMedication(index);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddOrEditDialog();
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   String _formatTime(DateTime dateTime) {
//     final hour = dateTime.hour.toString().padLeft(2, '0');
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }
// }

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:health_mate/utils/date_utils.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../models/medication.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class MedicationsScreen extends StatefulWidget {
//   const MedicationsScreen({super.key});

//   @override
//   _MedicationsScreenState createState() => _MedicationsScreenState();
// }

// class _MedicationsScreenState extends State<MedicationsScreen> {
//   late Box<Medication> medicationBox;

//   @override
//   void initState() {
//     super.initState();
//     medicationBox = Hive.box<Medication>('medicationsBox');
//     _requestNotificationPermission();
//   }
// Future<void> _requestNotificationPermission() async {
//   final status = await Permission.notification.status;
//   if (!status.isGranted) {
//     await Permission.notification.request();
//   }
// }
//   @override           // Jalo
//   void dispose() {
//     medicationBox.close();
//     super.dispose();
//   }

//   void _showAddMedicationDialog() {
//     final nameController = TextEditingController();
//     final dosageController = TextEditingController();
//     TimeOfDay? reminderTime;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             return AlertDialog(
//               title: Text('medications.add_medication'.tr()),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         labelText: 'medications.medication_name'.tr(),
//                       ),
//                     ),
//                     TextField(
//                       controller: dosageController,
//                       decoration: InputDecoration(
//                         labelText: 'medications.dosage'.tr(),
//                       ),
//                     ),
//                     SizedBox(height: 12.h),
//                     ElevatedButton(
//                       onPressed: () async {
//                         final time = await showTimePicker(
//                           context: context,
//                           initialTime: TimeOfDay.now(),
//                         );
//                         if (time != null) {
//                           setStateDialog(() {
//                             reminderTime = time;
//                           });
//                         }
//                       },
//                       child: Text(
//                         reminderTime == null
//                             ? 'medications.select_time'.tr()
//                             : 'medications.reminder_time: ${reminderTime!.format(context)}'
//                                   .tr(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('common.cancel'.tr()),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (nameController.text.isNotEmpty &&
//                         dosageController.text.isNotEmpty &&
//                         reminderTime != null) {
//                       final medication = Medication(
//                         name: nameController.text,
//                         dosage: dosageController.text,
//                         //reminderTime: _timeOfDayToDateTime(reminderTime!),
//                         reminderTime: DateUtilsHelper.timeOfDayToDateTime(
//                           reminderTime!,
//                         ),
//                       );
//                       medicationBox.add(medication);
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text('common.save'.tr()),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('medications.title'.tr())),
//       body: ValueListenableBuilder(
//         valueListenable: medicationBox.listenable(),
//         builder: (context, Box<Medication> box, _) {
//           final meds = box.values.toList();
//           if (meds.isEmpty) {
//             return Center(
//               child: Text('medications.no_medications_added_yet'.tr()),
//             );
//           }
//           return ListView.builder(
//             itemCount: meds.length,
//             itemBuilder: (context, index) {
//               final med = meds[index];
//               return ListTile(
//                 title: Text(med.name),
//                 subtitle: Text(
//                   'medications.dosage: ${med.dosage}\nmedications.reminder_time: ${DateUtilsHelper.formatTime(med.reminderTime)}'
//                       .tr(),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddMedicationDialog,
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
