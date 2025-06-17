import 'package:flutter/material.dart';
import '../widgets/settings.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FatherMessagePage extends StatelessWidget {
  const FatherMessagePage({Key? key}) : super(key: key);

  // Helper method for localization
  String itemName(String key) {
    return AppSettings.getNameValue(key);
  }

  @override
  Widget build(BuildContext context) {
    // Create a WebViewController
    final WebViewController controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // You can add a loading indicator here if needed
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              onWebResourceError: (WebResourceError error) {},
            ),
          )
          ..loadRequest(
            Uri.parse('https://liku-amare.me/2025/06/15/holy-sunday-morning/'),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(itemName('home_father_message')),
        elevation: 4,
        backgroundColor: Colors.deepPurple,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
