import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WebViewExample(),
      ),
    );

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late bool isLogged = false;

  late final WebViewController _controller;
  bool isExitApp = false;
  Future<void> getLoggedValue() async {
    final SharedPreferences prefs = await _prefs;
    isLogged = prefs.getBool('isLogged') ?? false;
    setState(() {
      prefs.setBool('isLogged', isLogged).then((bool success) {
        return isLogged;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    // #enddocregion platform_features

    getLoggedValue().then((value) => controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              debugPrint('allowing navigation to ${request.url}');
              if (request.url.substring(0, 6) == 'intent') {
                String questionBankUrl = request.url.substring(169, 268);
                _launchUrl(questionBankUrl);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onProgress: (int progress) {
              const CircularProgressIndicator();
            },
            onWebResourceError: (WebResourceError error) {},
            onUrlChange: (UrlChange change) async {
              if (change.url == 'https://www.p2a.academy/') {
                setState(() {
                  isExitApp = true;
                });
                final SharedPreferences prefs = await _prefs;

                setState(() {
                  prefs.setBool('isLogged', true).then(
                        (value) => isLogged,
                      );
                });
              } else {
                isExitApp = false;

                setState(() {});
              }

              debugPrint('url change to ${change.url}');
            },
            onPageFinished: (String url) {
              /// Remove Header and footer
              debugPrint('url page finish to $url');
              controller.runJavaScript(
                  "document.getElementsByTagName('header')[0].style.display='none'");
              controller.runJavaScript(
                  "document.getElementsByTagName('footer')[0].style.display='none'");
            }),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(
        Uri.parse(
          isLogged == true
              ? 'https://www.p2a.academy/'
              : 'https://www.p2a.academy/auth/login',
        ),
      ));

    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return isExitApp;
    } else {
      return isExitApp;
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
