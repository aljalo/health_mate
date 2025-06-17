import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/blood_sugar.dart';

class BloodSugarScreen extends StatefulWidget {
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
      appBar: AppBar(
        title: Text('Blood Sugar Management'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Last Blood Sugar Reading'),
                subtitle: lastEntry != null
                    ? Text(
                        '${lastEntry.sugarLevel} mg/dL\n${lastEntry.date.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 18),
                      )
                    : Text('No data yet'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: Icon(Icons.add),
              label: Text('Add New Reading'),
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
    final sugarController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Enter Blood Sugar'),
        content: TextField(
          controller: sugarController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Blood Sugar (mg/dL)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
