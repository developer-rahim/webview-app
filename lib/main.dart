import 'package:flutter/material.dart';
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
  late final WebViewController _controller;
  bool isExitApp = false;

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

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              debugPrint('allowing navigation to ${request.url}');

              return NavigationDecision.navigate;
            },
            onProgress: (int progress) {
              const CircularProgressIndicator();
            },
            onWebResourceError: (WebResourceError error) {},
            onUrlChange: (UrlChange change) {
              if (change.url == 'https://www.p2a.academy/') {
                setState(() {
                  isExitApp = true;
                });
                print(isExitApp);
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
          'https://www.p2a.academy/auth/login',
        ),
      );

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
//https://englishapps.nextlms.net/api/bkash/callback?paymentID=TR0011E81685871958882&status=success&apiVersion=1.2.0-beta