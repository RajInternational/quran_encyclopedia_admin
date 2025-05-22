import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/HadeesData.dart';

class DisplaySavedDataScreen extends StatefulWidget {
  @override
  _DisplaySavedDataScreenState createState() => _DisplaySavedDataScreenState();
}

class _DisplaySavedDataScreenState extends State<DisplaySavedDataScreen> {
  List<HadeesData> _savedHadees = [];

  @override
  void initState() {
    super.initState();
    _loadSavedHadees();
  }

  Future<void> _loadSavedHadees() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('savedHadeesData');
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _savedHadees = jsonList
            .map((json) => HadeesData.fromJson(json as Map<String, dynamic>))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Hadees Data'),
      ),
      body: _savedHadees.isEmpty
          ? Center(child: Text('No data found'))
          : ListView.builder(
              itemCount: _savedHadees.length,
              itemBuilder: (context, index) {
                final hadees = _savedHadees[index];
                return ListTile(
                  title: Text('${hadees.hadithNo}'),
                  // subtitle: Text(hadees.urdu ?? 'No description'),
                );
              },
            ),
    );
  }
}
