//通过 Overlay 实现 Toast
import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

//1、创建 overlayEntry
IpfsController ipfs = IpfsController();

class IpfsController {
  int _taskId = 0;
  Map<int, UploadCallbacks> _callbackMap = {};
  int _delay = 10;
  bool _isReady = false;
  String? _ext;
  late WebViewPlusController _controller;

  bool uploadFile(File file, String? ext, {Function(String)? onComplete, Function()? onTimeout}) {
    if (!_isReady) {
      return false;
    }
    _upload(_taskId, file, ext, _controller, Duration(seconds: _delay));
    _callbackMap[_taskId] = UploadCallbacks(onComplete, onTimeout);
    _taskId++;
    return true;
  }

  void _upload(int taskId, File file, String? ext, WebViewPlusController controller, Duration delay) {
    final bytes = file.readAsBytesSync();
    String head = "data:image/jpeg;base64,";
    if (ext != null) {
      head = head.replaceAll("jpeg", ext);
    }
    String base64Encode = head + base64.encode(bytes);
    // debugPrint("base64Encode=$base64Encode");
    var command = "window.nft.addBase64File($taskId,'$base64Encode',${delay.inMilliseconds})";
    print(command);
    controller.webViewController.runJavascript(command);
    // controller.webViewController.runJavascript("""
  // window.log('test')
  //       """);
  }
}

class IpfsNode {
  static bool nodeInserted = false;

  static void insert(BuildContext context) {
    if (nodeInserted) {
      return;
    }
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          top: 0,
          left: 0,
          child: Material(
            child: Container(
              width: 50,
              height: 50,
              child: IpfsWebpage(ipfs),
            ),
          ));
    });
    //插入到 Overlay中显示 OverlayEntry
    Overlay.of(context).insert(overlayEntry);
    nodeInserted = true;
    //
    // //延时两秒，移除 OverlayEntry
    // Future.delayed(Duration(seconds: 2)).then((value) {
    //   overlayEntry.remove();
    // });
  }

  static void upload(File file) {
    // ipfs.sta
  }
}

class IpfsWebpage extends StatefulWidget {
  final IpfsController ipfsController;

  const IpfsWebpage(
    this.ipfsController, {
    Key? key,
  }) : super(key: key);

  @override
  State<IpfsWebpage> createState() => _IpfsWebpageState();
}

class _IpfsWebpageState extends State<IpfsWebpage> {

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebViewPlus.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewPlus(
      javascriptMode: JavascriptMode.unrestricted,
      onWebResourceError: (e) {
        debugPrint(e.failingUrl);
      },
      javascriptChannels: <JavascriptChannel>{
        JavascriptChannel(
            name: "logHandler",
            onMessageReceived: (JavascriptMessage message) {
              // debugPrint("[webview] ${message.message}");
            }),
        JavascriptChannel(
            name: "onNodeReady",
            onMessageReceived: (JavascriptMessage message) {
              // debugPrint("onNodeReady");
              setState(() {
                widget.ipfsController._isReady = true;
              });
              // _upload(file, ext, _controller, Duration(seconds: delay));
            }),
        JavascriptChannel(
            name: "onUploadComplete",
            onMessageReceived: (JavascriptMessage message) {
              String json = message.message;
              Map map = jsonDecode(json);
              String cid = map['cid'];
              int taskId = map['task_id'];
              // debugPrint("onUploadComplete task_id=$taskId, cid=$cid");
              if (widget.ipfsController._callbackMap[taskId]?.onComplete != null) {
                widget.ipfsController._callbackMap[taskId]?.onComplete!(cid);
              }
              widget.ipfsController._callbackMap.remove(taskId);
            }),
      },
      initialUrl: 'assets/index.html',
      onWebViewCreated: (WebViewPlusController webViewController) {
        widget.ipfsController._controller = webViewController;
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
    );
  }
}

class UploadCallbacks {
  void Function(String)? onComplete;
  void Function()? onTimeout;

  UploadCallbacks(this.onComplete, this.onTimeout);
}
