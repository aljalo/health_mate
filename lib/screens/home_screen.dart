import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/blood_pressure.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<BloodPressure> bloodBox;

  @override
  void initState() {
    super.initState();
    bloodBox = Hive.box<BloodPressure>('bloodBox');
  }

  @override
  Widget build(BuildContext context) {
    final lastEntry = bloodBox.values.isNotEmpty ? bloodBox.values.last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('app_title')),
        actions: [
          // Drop down menu to switch language
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<Locale>(
              value: context.locale,
              underline: SizedBox(),
              icon: Icon(Icons.language, color: Colors.white),
              items: [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
    DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
    DropdownMenuItem(value: Locale('tr'), child: Text('Türkçe')),
    DropdownMenuItem(value: Locale('de'), child: Text('Deutsch')),
    DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  context.setLocale(locale);
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: Text(tr('last_bp_reading')),
                subtitle: lastEntry != null
                    ? Text(
                        '${lastEntry.systolic}/${lastEntry.diastolic} mmHg\n${lastEntry.date.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 18),
                      )
                    : Text(tr('no_data')),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: Icon(Icons.add),
              label: Text(tr('add_new_reading')),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        title: Text(tr('enter_bp')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: tr('systolic')),
            ),
            TextField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: tr('diastolic')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
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
                bloodBox.add(entry);
                setState(() {}); // refresh UI
                Navigator.pop(context);
              }
            },
            child: Text(tr('save')),
          ),
        ],
      ),
    );
  }
}
