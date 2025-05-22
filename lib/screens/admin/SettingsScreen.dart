import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.dividerColor),
          borderRadius: radius(8),
          color: white,
        ),
        child: Text('Settings', style: boldTextStyle()).center(),
      ),
    );
  }
}
