import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class WebViewScreen extends ConsumerStatefulWidget {
  final String url;
  final String title;

  const WebViewScreen(
    this.title,
    this.url, {
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _WebViewState();
}

class _WebViewState extends ConsumerState<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebViewPlus(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          String url = widget.url;
          if (!url.startsWith("https://")) {
            url = "https://$url";
          }
          controller.loadUrl(url);
        },
      ),
    );
  }
}
