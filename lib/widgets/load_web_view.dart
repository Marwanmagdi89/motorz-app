// ignore_for_file: prefer_const_constructors, unused_import, implementation_imports

import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prime_web/helpers/utils.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../widgets/no_internet_widget.dart';
import '../helpers/Constant.dart';
import 'package:provider/src/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/Strings.dart';
import '../provider/navigationBarProvider.dart';
import '../widgets/not_found.dart';

import '../helpers/Colors.dart';
import 'no_internet.dart';

class LoadWebView extends StatefulWidget {
  String url = '';
  bool webUrl = true;

  LoadWebView({required this.url, required this.webUrl, Key? key})
      : super(key: key);

  @override
  _LoadWebViewState createState() => _LoadWebViewState();
}

class _LoadWebViewState extends State<LoadWebView>
    with SingleTickerProviderStateMixin {
  final GlobalKey webViewKey = GlobalKey();

  // late PullToRefreshController _pullToRefreshController;
  CookieManager cookieManager = CookieManager.instance();
  InAppWebViewController? webViewController;
  double progress = 0;
  String url = '';
  int _previousScrollY = 0;
  late AnimationController animationController;
  late Animation<double> animation;
  final expiresDate =
      DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _validURL = false;
  bool canGoBack = false;

  @override
  void initState() {
    super.initState();
    _validURL = Uri.tryParse(widget.url)?.isAbsolute ?? false;

    // try {
    //   // _pullToRefreshController = PullToRefreshController(
    //   //   options: PullToRefreshOptions(color: primaryColor),
    //   //   onRefresh: () async {
    //   //     if (Platform.isAndroid) {
    //   //       webViewController!.reload();
    //   //     } else if (Platform.isIOS) {
    //   //       webViewController!.loadUrl(urlRequest: URLRequest(url: await webViewController!.getUrl()));
    //   //     }
    //   //   },
    //   // );
    // } on Exception catch (e) {
    //   // print(e);
    // }

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat();
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController)
      ..addListener(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    animationController.dispose();
    webViewController = null;
    super.dispose();
  }

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          useOnDownloadStart: true,
          javaScriptEnabled: true,
          javaScriptCanOpenWindowsAutomatically: true,
          cacheEnabled: true,
          supportZoom: false,
          userAgent:
              "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
          verticalScrollBarEnabled: false,
          horizontalScrollBarEnabled: false,
          transparentBackground: true,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true),
      android: AndroidInAppWebViewOptions(
        thirdPartyCookiesEnabled: true,
        allowFileAccess: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  Widget build(BuildContext context) {
    print(url);
    return GestureDetector(
      onHorizontalDragEnd: (dragEndDetails) async {
        // Swiping in right direction.
        if (dragEndDetails.primaryVelocity! > 0) {
          if (await webViewController!.canGoBack()) {
            webViewController!.goBack();
          } else {}
        }
      },
      child: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: InAppWebView(
          initialUrlRequest:
          URLRequest(url: Uri.parse(widget.url)),
          initialOptions: options,

          // pullToRefreshController: _pullToRefreshController,
          gestureRecognizers: <Factory<
              OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer()),
          },
          onWebViewCreated: (controller) async {
            webViewController = controller;
          },
          shouldOverrideUrlLoading:
              (controller, navigationAction) async {
            var url = navigationAction.request.url.toString();
            var uri = Uri.parse(url);

            if (Platform.isIOS && url.contains("geo")) {
              url = url.replaceFirst(
                  'geo://', 'http://maps.apple.com/');
            } else if (url.contains("tel:") ||
                url.contains("mailto:") ||
                url.contains("play.google.com") ||
                url.contains("maps") ||
                url.contains("messenger.com")) {
              url = Uri.encodeFull(url);
              try {
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri);
                } else {
                  launchUrl(uri);
                }
                return NavigationActionPolicy.CANCEL;
              } catch (e) {
                launchUrl(uri);
                return NavigationActionPolicy.CANCEL;
              }
            } else if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
            ].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                // Launch the App
                await launchUrl(
                  uri,
                );
                // and cancel the request
                return NavigationActionPolicy.CANCEL;
              }
            }
            print(
                "navigationAction.request.url ${navigationAction.request.url}");
            if (Platform.isIOS && (navigationAction.request.url
                .toString()
                .contains("https://wa.me/") ||
                navigationAction.request.url
                    .toString()
                    .contains("whatsapp://send"))) {
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
          onDownloadStartRequest:
              (controller, downloadStartRrquest) async {
            // print('=--download--$url');

            enableStoragePermision().then((status) async {
              String url = downloadStartRrquest.url.toString();

              if (status == true) {
                try {
                  Dio dio = Dio();
                  String fileName;
                  if (url.toString().lastIndexOf('?') > 0) {
                    fileName = url.toString().substring(
                        url.toString().lastIndexOf('/') + 1,
                        url.toString().lastIndexOf('?'));
                  } else {
                    fileName = url.toString().substring(
                        url.toString().lastIndexOf('/') + 1);
                  }
                  String savePath = await getFilePath(fileName);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                    content: const Text('Downloading file..'),
                  ));
                  await dio.download(url.toString(), savePath,
                      onReceiveProgress: (rec, total) {});

                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                    content: const Text('Download Complete'),
                  ));
                } on Exception catch (_) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                    content: const Text('Downloading failed'),
                  ));
                }
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(
                  content: const Text('Permision denied'),
                ));
              }
            });
          },
          onUpdateVisitedHistory:
              (controller, url, androidIsReload) async {
            setState(() {
              this.url = url.toString();
            });
          },
          onConsoleMessage: (controller, consoleMessage) async {
            print("consoleMessage.message");
            print(consoleMessage.message);
            if (consoleMessage.message
                .contains("share_event;")) {
              String data = consoleMessage.message
                  .replaceAll("share_event;", "")
                  .trim();
              Map values = jsonDecode(data);
              print(jsonDecode(data));
              print(jsonDecode(data)['title']);

              Share.shareWithResult(
                "${values['title']}\nhttps://motorzkw.com${values['url']}\n${values['text']}",
                subject: '',
              );
            }
            if (consoleMessage.message
                .contains("whatsapp_event;")) {
              String data = consoleMessage.message
                  .replaceAll("whatsapp_event;", "")
                  .trim();
              String iosUrl =
                  "https://api.whatsapp.com/send/?phone=%2B${data.replaceAll("+", '')}&text&type=phone_number&app_absent=0";
              print("========= $data");

              if (Platform.isIOS && await canLaunchUrl(Uri.parse(iosUrl))) {
                await launchUrl(Uri.parse(iosUrl));
              }
            }
          },
        ),
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (mounted) {
      context.read<NavigationBarProvider>().animationController.reverse();
    }
    if (!_validURL) {
      return Future.value(true);
    }
    if (await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Future<bool> requestPermission() async {
    final status = await Permission.storage.status;

    if (status == PermissionStatus.granted) {
      return true;
    } else if (status != PermissionStatus.granted) {
      //
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        // await openAppSettings();
        return false;
      }
    }
    return true;
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = '/storage/emulated/0/Download';
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    path = '$externalStorageDirPath/$uniqueFileName';
    return path;
  }
}
