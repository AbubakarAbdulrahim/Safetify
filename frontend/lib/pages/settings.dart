import 'package:flutter/material.dart';
import '../constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});



  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _location = true;
  bool _dataSharing = false;
  final bool _loading = false;
  String _theme = 'Light';

void _save() {
    setState(() {
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'), leading: BackButton()),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            Align(alignment: Alignment.centerLeft, child: Text('Account', style: TextStyle(fontWeight: FontWeight.w700))),
            SizedBox(height: 8),
            _tile('Change Password', onTap: () {}),
            _tile('Language', onTap: () {}),
            SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('Privacy', style: TextStyle(fontWeight: FontWeight.w700))),
            SizedBox(height: 8),
            SwitchListTile(
              title: Text('Location Services'),
              value: _location,
              onChanged: (v) => setState(() => _location = v),
              secondary: Icon(Icons.location_on_rounded, color: AppColors.safetyBlue),
            ),
            SwitchListTile(
              title: Text('Data Sharing'),
              value: _dataSharing,
              onChanged: (v) => setState(() => _dataSharing = v),
              secondary: Icon(Icons.storage_rounded, color: AppColors.safetyBlue),
            ),
            SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('App', style: TextStyle(fontWeight: FontWeight.w700))),
            SizedBox(height: 8),
            Row(
              children: [
                SizedBox(width: 2,),
                Icon(Icons.palette_rounded, color: AppColors.safetyBlue),
                SizedBox(width: 12),
                Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                Spacer(),
                ChoiceChip(label: Text('Light'), selected: _theme=='Light', onSelected: (s) => setState(() => _theme='Light')),
                SizedBox(width: 8),
                ChoiceChip(label: Text('Dark'), selected: _theme=='Dark', onSelected: (s) => setState(() => _theme='Dark')),
              ],
            ),
            Spacer(),
            const SizedBox(height: 20),
              _loading
                ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.safetyBlue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    ),
                  ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _tile(String label, {VoidCallback? onTap}) {
    return ListTile(title: Text(label), trailing: Icon(Icons.chevron_right_rounded), onTap: onTap);
  }
}
