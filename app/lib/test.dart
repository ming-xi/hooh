import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:pretty_json/pretty_json.dart';
import 'package:app/extensions/extensions.dart';
import 'package:app/providers.dart';
import 'package:app/ui/pages/test_uploading_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/ipfs_node.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/file_utils.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowCompression: false);
                //
                // if (result != null) {
                //   File file = File(result.files.single.path!);
                //   String? ext = result.files.single.extension;
                //   bool uploadSuccess = ipfs.uploadFile(file, ext, onComplete: (cid) {
                //     showDialog(
                //         context: context,
                //         builder: (context) {
                //           return AlertDialog(
                //             title: const Text("成功"),
                //             content: Text("CID=$cid"),
                //             actions: [
                //               TextButton(
                //                   onPressed: () {
                //                     Util.launchURL("https://nftstorage.link/ipfs/$cid");
                //                   },
                //                   child: const Text("查看（nft.storage）")),
                //               TextButton(
                //                   onPressed: () {
                //                     Util.launchURL("https://ipfs.io/ipfs/$cid");
                //                   },
                //                   child: const Text("查看（ipfs）"))
                //             ],
                //           );
                //         });
                //   }, onTimeout: () {
                //     showDialog(
                //         context: context,
                //         builder: (context) {
                //           return const AlertDialog(
                //             title: Text("失败"),
                //             content: Text("请求超时"),
                //           );
                //         });
                //   });
                //   if (!uploadSuccess) {
                //     showDialog(
                //         context: context,
                //         builder: (context) {
                //           return const AlertDialog(
                //             title: Text("失败"),
                //             content: Text("IPFS 未就绪"),
                //           );
                //         });
                //   }
                // } else {
                //   // User canceled the picker
                // }
              },
              child: const Text("select file"),
            ),
            ElevatedButton(
                onPressed: () {
                  // Toast.show(context: context, message: "信息已经提交!");
                  IpfsNode.insert(context);
                },
                child: Text("insert")),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TestUploadingAvatarScreen(),
                  ));
                },
                child: Text("push")),
            ElevatedButton(
                onPressed: () {
                  // network.getUser("283bc4ee-e489-452f-9827-a15946cf9656").catchError((error, stackTrace){
                  network.getUserInfo("4ee-e489-452f-9827-a15946cf9656").catchError((error, stackTrace) {
                    debugPrint(error.toString());
                  }).then((value) {
                    showDialog(
                        context: context,
                        builder: (e) => AlertDialog(
                              title: Text("用户"),
                              content: Text(prettyJson(value)),
                            ));
                  });
                },
                child: Text("test user")),
            ElevatedButton(
                onPressed: () {
                  String key = "test key";
                  if (preferences.hasKey(key)) {
                    preferences.putString(key, "123");
                    showDialog(
                        context: context,
                        builder: (e) => AlertDialog(
                              title: Text(key),
                              content: Text("覆盖设置为：" + preferences.getString(key)!),
                            ));
                  } else {
                    preferences.putString(key, "test value");
                    showDialog(
                        context: context,
                        builder: (e) => AlertDialog(
                              title: Text(key),
                              content: Text("设置为：" + preferences.getString(key)!),
                            ));
                  }
                },
                child: Text("set preferences")),
            ElevatedButton(
                onPressed: () {
                  String key = "test key";
                  if (preferences.hasKey(key)) {
                    showDialog(
                        context: context,
                        builder: (e) => AlertDialog(
                              title: Text(key),
                              content: Text(preferences.getString(key)!),
                            ));
                  } else {
                    showDialog(
                        context: context,
                        builder: (e) => AlertDialog(
                              title: Text(key),
                              content: Text("未设置"),
                            ));
                  }
                },
                child: Text("get preferences"))
          ],
        ),
      ),
    );
  }
}

class TestUploadingAvatarScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<TestUploadingPageModel, TestUploadingPageModelState> provider = StateNotifierProvider((ref) {
    return TestUploadingPageModel(TestUploadingPageModelState(uploading: false, imageUrl: null));
  });

  TestUploadingAvatarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TestUploadingAvatarScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestUploadingAvatarScreen> {
  @override
  Widget build(BuildContext context) {
    TestUploadingPageModel model = ref.watch(widget.provider.notifier);
    TestUploadingPageModelState modelState = ref.watch(widget.provider);
    String imageUrl = modelState.imageUrl ?? "";
    debugPrint("build page modelState.key=${network.getS3ImageKey(imageUrl)}");
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              HoohImage(
                imageUrl: imageUrl,
                size: 100,
              ),
              SizedBox(
                height: 24,
              ),
              ElevatedButton(
                onPressed: () async {
                  LoginResponse loginResponse = await network.login("app_test1", "123456");
                  network.setUserToken(loginResponse.jwtResponse.accessToken);
                  model.updateState(modelState.copyWith(imageUrl: loginResponse.user.avatarUrl));

                  Toast.showSnackBar(context, "success");
                },
                child: Text("login"),
                style: RegisterStyles.flatBlackButtonStyle(),
              ),
              SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: modelState.uploading
                    ? null
                    : () {
                        // FileUtil.pickFile(context).then((file) {
                        //   if (file == null) {
                        //     return;
                        //     model.uploadFile("da599f8e-cd49-443f-9e78-fa3f1394de0c", file!);
                        //   }
                        // });
                        FileUtil.pickImage().then((file) async {
                          if (file == null) {
                            return;
                          }
                          Toast.showSnackBar(context, "uploading");
                          String key = await model.uploadFile("da599f8e-cd49-443f-9e78-fa3f1394de0c", file);
                          await model.changeAvatar("da599f8e-cd49-443f-9e78-fa3f1394de0c", key);
                          Toast.showSnackBar(context, "success");
                        });
                      },
                child: Text("select file to upload"),
                style: RegisterStyles.flatBlackButtonStyle(),
              ),
              SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(globalDarkModeProvider.state).state = !ref.read(globalDarkModeProvider.state).state;
                },
                child: Text("toggle dark mode"),
                style: RegisterStyles.flatBlackButtonStyle(),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("test"),
      ),
    );
  }
}

class TestIpfsUploadingScreen extends StatefulWidget {
  final File file;
  final String? ext;

  const TestIpfsUploadingScreen(
    this.file,
    this.ext, {
    Key? key,
  }) : super(key: key);

  @override
  State<TestIpfsUploadingScreen> createState() => _TestIpfsUploadingScreenState();
}

class _TestIpfsUploadingScreenState extends State<TestIpfsUploadingScreen> {
  late WebViewPlusController _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebViewPlus.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            Visibility(
              visible: true,
              child: WebViewPlus(
                javascriptMode: JavascriptMode.unrestricted,
                onWebResourceError: (e) {
                  debugPrint(e.failingUrl);
                },
                javascriptChannels: <JavascriptChannel>{
                  JavascriptChannel(
                      name: "onNodeReady",
                      onMessageReceived: (JavascriptMessage message) {
                        debugPrint("onNodeReady");
                        upload();
                      }),
                  JavascriptChannel(
                      name: "onUploadComplete",
                      onMessageReceived: (JavascriptMessage message) {
                        String cid = message.message;
                        debugPrint("onUploadComplete cid=$cid");
                      }),
                },
                // initialUrl: 'about:blank',
                // initialUrl: 'http://192.168.31.136:8888',
                initialUrl: 'assets/index.html',
                onWebViewCreated: (WebViewPlusController webViewController) {
                  _controller = webViewController;
                },
                onPageStarted: (String url) {},
                onPageFinished: (String url) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void upload() {
    File file = widget.file;
    final bytes = file.readAsBytesSync();
    String head = "data:image/jpeg;base64,";
    String? ext = widget.ext;
    if (ext != null) {
      head = head.replaceAll("jpeg", ext);
    }
    String base64Encode = head + base64.encode(bytes);
    debugPrint("base64Encode=$base64Encode");
    _controller.webViewController.runJavascript("addBase64File('$base64Encode')");
  }
}

class Util {
  static void launchURL(String url) async {
    if (!await launch(url)) throw '无法打开 $url';
  }

  static Future<void> showMyDialog(BuildContext context, File file, String? ext, {Function(String)? onComplete, Function()? onTimeout}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        late WebViewPlusController _controller;
        bool isShown = true;
        int delay = 10;
        var dialog = AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator())),
              Visibility(
                visible: true,
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: WebViewPlus(
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebResourceError: (e) {
                      debugPrint(e.failingUrl);
                    },
                    javascriptChannels: <JavascriptChannel>{
                      JavascriptChannel(
                          name: "onNodeReady",
                          onMessageReceived: (JavascriptMessage message) {
                            debugPrint("onNodeReady");
                            _upload(file, ext, _controller, Duration(seconds: delay));
                          }),
                      JavascriptChannel(
                          name: "onUploadComplete",
                          onMessageReceived: (JavascriptMessage message) {
                            String cid = message.message;
                            debugPrint("onUploadComplete cid=$cid");
                            Navigator.of(context).pop();
                            isShown = false;
                            if (onComplete != null) {
                              onComplete(cid);
                            }
                          }),
                    },
                    initialUrl: 'assets/index.html',
                    onWebViewCreated: (WebViewPlusController webViewController) {
                      _controller = webViewController;
                    },
                    onPageStarted: (String url) {},
                    onPageFinished: (String url) {},
                  ),
                ),
              ),
            ],
          ),
        );
        Timer(
          Duration(seconds: 10 + delay),
          () {
            if (!isShown) {
              return;
            }
            Navigator.of(context).pop();
            if (onTimeout != null) {
              onTimeout();
            }
          },
        );
        return dialog;
      },
    );
  }

  static void _upload(File file, String? ext, WebViewPlusController controller, Duration delay) {
    final bytes = file.readAsBytesSync();
    String head = "data:image/jpeg;base64,";
    if (ext != null) {
      head = head.replaceAll("jpeg", ext);
    }
    String base64Encode = head + base64.encode(bytes);
    // debugPrint("base64Encode=$base64Encode");
    controller.webViewController.runJavascript("addBase64File('$base64Encode',${delay.inMilliseconds})");
  }
}
