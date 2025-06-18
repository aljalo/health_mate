import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/theme_mode_enum.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  late AppThemeMode appThemeMode;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settingsBox');
    appThemeMode = settingsBox.get(
      'themeMode',
      defaultValue: AppThemeMode.system,
    );
  }

  void _changeTheme(AppThemeMode mode) {
    setState(() {
      appThemeMode = mode;
      settingsBox.put('themeMode', mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language
            ListTile(
              title: Text('settings.language'.tr()),
              trailing: DropdownButton<Locale>(
                value: context.locale,
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
            Divider(),

            // Theme
            ListTile(
              title: Text('settings.theme'.tr()),
              trailing: DropdownButton<AppThemeMode>(
                value: appThemeMode,
                onChanged: (AppThemeMode? mode) {
                  if (mode != null) {
                    _changeTheme(mode);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: AppThemeMode.system,
                    child: Text('settings.system'),
                  ),
                  DropdownMenuItem(
                    value: AppThemeMode.light,
                    child: Text('settings.light'),
                  ),
                  DropdownMenuItem(
                    value: AppThemeMode.dark,
                    child: Text('settings.dark'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
