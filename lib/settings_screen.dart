import 'package:chat_app_gpt/message_management.dart';
import 'package:chat_app_gpt/message_model.dart';
import 'package:easy_settings/easy_settings.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.callback});

  final Function callback;

  static List<SettingsCategory> settingsCategories = [
  SettingsCategory(
      title: "Setting app",
      iconData: Icons.settings,
      settingsSections: [
        SettingsSection(settingsElements: [
          BoolSettingsProperty(
              key: 'auto_reading',
              title: 'Auto reading', 
              defaultValue: true, 
              iconData: Icons.multitrack_audio),
          EnumSettingsProperty(
              key: "language",
              title: "Language",
              defaultValue: 0,
              iconData: Icons.language,
              choices: ["English", "Vietnamese"],
              ),
        ])
      ])
];

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        ),
        body: Column(
          children: [
            const EasySettingsWidget(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(flex: 2, child: Container()),
                Expanded( 
                  flex: 8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.0),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete History Chat"),
                          content: const Text("Are you sure you want to delete all history chat?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async{
                                await MessageManagement.db.deleteAll();
                                widget.callback();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        )
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete_outline), 
                        Text("Delete History Chat"),
                      ],
                    )
                  )
                ),
                Expanded(flex: 2, child: Container()),
              ],
            ),
            ],
          )
      );
  }
}