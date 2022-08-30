import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:app/test_regex.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:universal_io/io.dart';

import 'package:app/global.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/ipfs_node.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:jshare_flutter_plugin/jshare_flutter_plugin.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class TestMenuScreen extends ConsumerStatefulWidget {
  const TestMenuScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestMenuScreenState();
}

class _TestMenuScreenState extends ConsumerState<TestMenuScreen> {
  late int networkType;

  @override
  void initState() {
    super.initState();
    networkType = preferences.getInt(Preferences.KEY_SERVER) ?? Network.TYPE_PRODUCTION;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test menu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainStyles.blueButton(
              ref,
              "测试（勿点）",
              () {
                // showHoohDialog(
                //     context: context,
                //     builder: (context) {
                //       return LoadingDialog(LoadingDialogController());
                //     });
                showGeneralDialog(
                  barrierDismissible: true,
                  barrierLabel: '',
                  barrierColor: Colors.black.withOpacity(0.25),
                  // transitionDuration: Duration(milliseconds: 500),
                  pageBuilder: (ctx, anim1, anim2) => AlertDialog(
                    title: Text('blured background'),
                    content: Text('background should be blured and little bit darker '),
                    elevation: 2,
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8 * anim1.value, sigmaY: 8 * anim1.value),
                    child: FadeTransition(
                      child: child,
                      opacity: anim1,
                    ),
                  ),
                  context: context,
                );
              },
            ),
            SizedBox(
              height: 16,
            ),
            MainStyles.blueButton(
              ref,
              "测试正则表达式",
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TestRegexScreen()));
              },
            ),
            SizedBox(
              height: 16,
            ),
            MainStyles.blueButton(
              ref,
              "清除引导页和缓存等记录",
              () {
                preferences.clear();
                showSnackBar(context, "已清除");
              },
            ),
            SizedBox(
              height: 16,
            ),
            MainStyles.blueButton(
              ref,
              "快速登录",
              () {
                showQuickLoginDialog();
              },
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "选择服务器：",
                    style: TextStyle(color: designColors.dark_01.auto(ref)),
                  ),
                ),
                DropdownButton<int>(
                  value: networkType,
                  dropdownColor: designColors.light_00.auto(ref),
                  style: TextStyle(color: designColors.dark_01.auto(ref)),
                  items: [Network.TYPE_LOCAL, Network.TYPE_STAGING, Network.TYPE_PRODUCTION]
                      .map((e) => DropdownMenuItem<int>(
                            child: Text(Network.SERVER_HOST_NAMES[e]!),
                            value: e,
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    preferences.putInt(Preferences.KEY_SERVER, value);
                    network.reloadServerType();
                    handleUserLogout(ref);
                    setState(() {
                      networkType = value;
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showQuickLoginDialog() {
    List<dynamic> list = json.decode(preferences.getString(Preferences.KEY_HISTORY_USER_LOGIN_INFO) ?? "[]");
    List<UserLoginHistory> history = list.map((e) => UserLoginHistory.fromJson(e)).toList();
    history = history.where((element) => element.networkType == networkType).toList();
    if (history.isEmpty) {
      showSnackBar(context, "尚未在${Network.SERVER_HOST_NAMES[networkType]!}登录过任何账号");
      return;
    }
    showHoohDialog(
        context: context,
        builder: (popContext) {
          return AlertDialog(
              contentPadding: EdgeInsets.symmetric(vertical: 16),
              title: Text("选择用户"),
              content: SizedBox(
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (listContext, index) {
                    UserLoginHistory item = history[index];
                    return ListTile(
                      dense: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        handleUserLogout(ref);
                        network.requestAsync<LoginResponse>(network.loginWithEncryptedPassword(item.username, item.encryptedPassword), (response) {
                          handleUserLogin(ref, response.user, response.jwtResponse.accessToken, null);
                          showSnackBar(context, "登录成功");
                        }, (error) => showCommonRequestErrorDialog(ref, context, error));
                      },
                      leading: HoohImage(
                        imageUrl: item.avatar,
                        cornerRadius: 100,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: designColors.dark_01.auto(ref)),
                      ),
                      subtitle: Text(
                        item.username,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: designColors.dark_03.auto(ref)),
                      ),
                      trailing: Text(
                        formatDate(context, item.lastLoginAt),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: designColors.dark_03.auto(ref)),
                      ),
                    );
                  },
                  itemCount: history.length,
                ),
              ));
        });
  }
}

class TestWidgetScreen extends ConsumerStatefulWidget {
  const TestWidgetScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestWidgetScreenState();
}

class _TestWidgetScreenState extends ConsumerState<TestWidgetScreen> {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Center(
    //     child: PostView(post: Post.fromJson(json.decode(JSON))),
    //   ),
    // );
    // return Scaffold(
    //   body: Center(
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         CommentComposeView(provider: StateNotifierProvider((ref) {
    //           return CommentComposeWidgetViewModel(CommentComposeWidgetModelState.init(Post.fromJson(json.decode(JSON))));
    //         })),
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      body: Center(),
    );
  }
}

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
                //     showHoohDialog(
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
                //     showHoohDialog(
                //         context: context,
                //         builder: (context) {
                //           return const AlertDialog(
                //             title: Text("失败"),
                //             content: Text("请求超时"),
                //           );
                //         });
                //   });
                //   if (!uploadSuccess) {
                //     showHoohDialog(
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
                  // network.getUser("283bc4ee-e489-452f-9827-a15946cf9656").catchError((error, stackTrace){
                  network.getUserInfo("4ee-e489-452f-9827-a15946cf9656").catchError((error, stackTrace) {
                    debugPrint(error.toString());
                  }).then((value) {
                    showHoohDialog(
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
                    showHoohDialog(
                        context: context,
                        builder: (e) => AlertDialog(
                              title: Text(key),
                              content: Text("覆盖设置为：" + preferences.getString(key)!),
                            ));
                  } else {
                    preferences.putString(key, "test value");
                    showHoohDialog(
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
                    showHoohDialog(
                        context: context,
                        builder: (e) => AlertDialog(
                              title: Text(key),
                              content: Text(preferences.getString(key)!),
                            ));
                  } else {
                    showHoohDialog(
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
    return showHoohDialog<void>(
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
