import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/screens/SplashScreen.dart';
import 'package:quizeapp/services/AppSettingService.dart';
import 'package:quizeapp/services/CategoryService.dart';
import 'package:quizeapp/services/DictionaryWordService.dart';
import 'package:quizeapp/store/AppStore.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:url_strategy/url_strategy.dart';

AppStore appStore = AppStore();

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

CategoryService categoryService = CategoryService();
AppSettingService appSettingService = AppSettingService();
DictionaryWordService dictionaryWordService = DictionaryWordService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  defaultRadius = 6;
  defaultAppButtonRadius = 4;
  defaultAppBarElevation = 2.0;

  defaultAppButtonTextColorGlobal = colorPrimary;
  appButtonBackgroundColorGlobal = Colors.white;

  desktopBreakpointGlobal = 700.0;

  await initialize();

  defaultAppButtonShapeBorder =
      OutlineInputBorder(borderSide: BorderSide(color: colorPrimary));

  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));

  if (appStore.isLoggedIn) {
    appStore.setUserId(getStringAsync(USER_ID));
    appStore.setAdmin(getBoolAsync(IS_ADMIN));
    appStore.setSuperAdmin(getBoolAsync(IS_SUPER_ADMIN));
    appStore.setFullName(getStringAsync(FULL_NAME));
    appStore.setUserEmail(getStringAsync(USER_EMAIL));
    appStore.setUserProfile(getStringAsync(PROFILE_IMAGE));
  }

  setTheme();

  if (isMobile || isWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: "AIzaSyDxTk3Vhu4qYKw3sUtBg6lHFfa6itfWlvE",
      authDomain: "search-quran-raj.firebaseapp.com",
      projectId: "search-quran-raj",
      storageBucket: "search-quran-raj.appspot.com",
      messagingSenderId: "267518604153",
      appId: "1:267518604153:web:0687796526ccb2136ff5a8",
    )).then((value) {
      //FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      //MobileAds.instance.initialize();
    });
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        title: mAppName,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
