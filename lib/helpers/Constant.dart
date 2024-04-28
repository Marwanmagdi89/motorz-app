import 'package:flutter/material.dart';
import 'package:prime_web/helpers/icons.dart';

import 'Strings.dart';

const appName = 'Motorz';

const String appbartitle = 'Motorz';
const String andoidPackageName = 'com.motorz.app';

//change this url to set your URL in app
String webinitialUrl = 'https://motorzkw.com/';
const String firstTabUrl = 'https://motorzkw.com/car/sale';

//keep local content of pages of setting screen
const String aboutPageURL = '';
const String privacyPageURL = '';
const String termsPageURL = '';

//Change App id of android and IOS app
const String androidAppId = andoidPackageName;

const String iOSAppId = '';

const String shareAppTitle = appName;
const String shareiOSAppMessage =
    'Download $appName App from this link : $appstoreURLIos';
const String shareAndroidAppMessge =
    'Download $appName App from this link : $playstoreURLAndroid';

const String playstoreURLAndroid =
    'https://play.google.com/store/apps/details?id=$androidAppId';
const String appstoreURLIos = 'https://testflight.apple.com/join/l6t5kD1G';

//To turn on/off ads
const bool showInterstitialAds = false;
const bool showBannerAds = false;
const bool showOpenAds = false;

//To turn on/off display of bottom navigation bar
const bool showBottomNavigationBar = false;

//To turn on/off display of floating action button
const bool showFloatingActionButton = false;

//To show/remove splash screen
const bool showSplashScreen = false;

//To show/remove onboarding screen
const bool showOnboardingScreen = false;

//To remove/display header/footer of website
const bool hideHeader = false;
const bool hideFooter = false;

//Ids for interstitial Ad
const androidInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
const iosInterstitialAdId = 'ca-app-pub-3940256099942544/4411468910';

//Ids for banner Ad
const androidBannerAdId = 'ca-app-pub-3940256099942544/6300978111';
const iosBannerAdId = 'ca-app-pub-3940256099942544/2934735716';

//Ids for app open Ad
const androidOpenAdId = 'ca-app-pub-3940256099942544/3419835294';
const iosOpenAdId = 'ca-app-pub-3940256099942544/5662855259';

//icon to set when get firebase messages
const String notificationIcon = '@mipmap/ic_launcher_squircle';

//path to icons   *** don't change these values**
const String iconPath = 'assets/icons/';

//turn on/off enable storage permission
const bool isStoragePermissionEnabled = false;

//add / remove tabs here
List navigationTabs(BuildContext context) => [
      {
        'url': firstTabUrl,
        'label': CustomStrings.demo,
        'icon': Theme.of(context).colorScheme.demoIcon
      },
      {
        'url': webinitialUrl,
        'label': CustomStrings.home,
        'icon': Theme.of(context).colorScheme.homeIcon
      },
    ];

//copy your  one-signal android app id
const oneSignalAndroidAppId = 'a0515584-12a5-48f6-af79-9cdc9317021d';

//copy your  one-signal ios app id
const oneSignalIOSAppId = 'a0515584-12a5-48f6-af79-9cdc9317021d';
