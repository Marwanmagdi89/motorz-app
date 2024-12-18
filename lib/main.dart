// ignore_for_file: prefer_const_constructors, unused_import, unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/Constant.dart';
import '../provider/navigationBarProvider.dart';
import '../provider/theme_provider.dart';
import '../screens/main_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/admob_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences pref;
AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'com.motorz.app', // id
    'Motorz', // title
    description: 'Motorz', // description
    importance: Importance.high,
    playSound: true);

// Create a global instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
enableStoragePermision() async {
  if (Platform.isIOS) {
    bool permissionGiven = await Permission.storage.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.storage.request()).isGranted;
      return permissionGiven;
    }
    return permissionGiven;
  }
  //if it is for android
  final deviceInfoPlugin = DeviceInfoPlugin();
  final androidDeviceInfo = await deviceInfoPlugin.androidInfo;

  if (androidDeviceInfo.version.sdkInt < 33) {
    bool permissionGiven = await Permission.storage.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.storage.request()).isGranted;
      return permissionGiven;
    }

    return permissionGiven;
  } else {
    bool permissionGiven = await Permission.photos.isGranted;

    if (!permissionGiven) {
      permissionGiven = (await Permission.photos.request()).isGranted;

      return permissionGiven;
    }
    return permissionGiven;
  }
}

Future main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //when we have to communicate to flutter framework before initializing app
  // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //   print("Accepted permission: $accepted");
  // });
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // Set this to your desired color
    systemNavigationBarIconBrightness: Brightness.dark, // Change the icon color
  ));
  pref = await SharedPreferences.getInstance();
  if (showInterstitialAds) {
    AdMobService.initialize();
  }
  if (isStoragePermissionEnabled) {
    await enableStoragePermision();
  }
  print("Requisting camera permission");
  if ((await Permission.camera.request()).isGranted) {
    print("Camera permission granted");
  } else {
    print("Camera permission denied");
  }

  await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  bool isNavVisible = true;
  int counter = 0;
  SharedPreferences.getInstance().then((prefs) {
    prefs.setInt('counter', counter);
    var isDarkTheme =
        prefs.getBool("isDarkTheme") ?? ThemeMode.system == ThemeMode.dark
            ? true
            : false;
    return runApp(
      ChangeNotifierProvider<ThemeProvider>(
        child: MyApp(),
        create: (BuildContext context) {
          return ThemeProvider(isDarkTheme);
        },
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      /* start--uncommnet  below 2 lines to enable landscape mode */
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight
      /*end */
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationBarProvider>(
            create: (_) => NavigationBarProvider())
      ],
      child: Consumer<ThemeProvider>(builder: (context, value, child) {
        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          themeMode: value.getTheme(),
          color: Colors.white,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          home: Visibility(
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              visible: true,
              child: SplashScreen()),
        );
      }),
    );
  }
}
