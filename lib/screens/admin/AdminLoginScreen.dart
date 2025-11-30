import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/screens/admin/AdminDashboardScreen.dart';
import 'package:quizeapp/services/AuthService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../../main.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var formKey1 = GlobalKey<FormState>();

  TextEditingController numberController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');

  FocusNode passFocus = FocusNode();
  FocusNode numberFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> signIn() async {
    if (formKey1.currentState!.validate()) {
      formKey1.currentState!.save();
      appStore.setLoading(true);

      // Login credentials: number = 741852, password = hamdani123
      if (numberController.text.trim() == '741852' &&
          passwordController.text == 'hamdani123') {
        toast('Logged In Successfully', length: Toast.LENGTH_LONG);
        appStore.setLoggedIn(true);
        setValue(IS_LOGGED_IN, true);
        setValue(USER_EMAIL, numberController.text.trim());
        AdminDashboardScreen().launch(context, isNewTask: true);
      } else {
        toast('Invalid credentials. Please check your number and password.', length: Toast.LENGTH_LONG);
        appStore.setLoggedIn(false);
      }
      
      appStore.setLoading(false);
    }
  }

  @override
  void dispose() {
    numberController.dispose();
    passwordController.dispose();
    passFocus.dispose();
    numberFocus.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: formKey,
      body: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Form(
              key: formKey1,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Image.asset('assets/icons/splash_app_logo.png',
                        height: 100),
                    16.height,
                    Text(
                      'Login to Continue',
                      style: boldTextStyle(
                        size: 22,
                      ),
                    ),
                    20.height,
                    AppTextField(
                      controller: numberController,
                      textFieldType: TextFieldType.PHONE,
                      decoration: inputDecoration(labelText: 'Number'),
                      nextFocus: passFocus,
                      autoFocus: true,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Number is required';
                        }
                        return null;
                      },
                    ),
                    8.height,
                    AppTextField(
                      controller: passwordController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: passFocus,
                      decoration: inputDecoration(labelText: 'Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                      onFieldSubmitted: (s) {
                        signIn();
                      },
                    ),
                    8.height,
                    AppButton(
                      text: 'login',
                      textStyle: boldTextStyle(color: white),
                      color: colorPrimary,
                      onTap: () {
                        signIn();
                      },
                      width: context.width(),
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        ),
      ).center(),
    );
  }
}
