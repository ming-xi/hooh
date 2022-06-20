import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/extensions/extensions.dart';
import 'package:app/global.dart';
import 'package:app/launcher.dart';
import 'package:app/test_uploading_view_model.dart';
import 'package:app/ui/pages/me/activities.dart';
import 'package:app/ui/pages/user/register/set_badge.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/ipfs_node.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/ui/widgets/user_activity_view.dart';
import 'package:app/utils/file_utils.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
            ElevatedButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => TestWidgetScreen()));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserActivityScreen(userId: "da599f8e-cd49-443f-9e78-fa3f1394de0c")));
                  // Navigator.popUntil(context,ModalRoute.withName("/home"));
                  // popToHomeScreen(context);
                },
                child: Text("test screen")),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
                onPressed: () {
                  handleUserLogout(ref);
                  // ref.read(globalUserInfoProvider.state).state = null;
                  // preferences.putString(Preferences.KEY_USER_INFO, null);
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => StartScreen()),
                  //   (route) => false,
                  // );
                  Navigator.pop(context);
                },
                child: Text("log out")),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
                onPressed: () {
                  preferences.clear();
                },
                child: Text("clear preferences")),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: Text("choose server:"),
                ),
                DropdownButton<int>(
                  value: networkType,
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
}

class TestWidgetScreen extends ConsumerStatefulWidget {
  const TestWidgetScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestWidgetScreenState();
}

class _TestWidgetScreenState extends ConsumerState<TestWidgetScreen> {
  static const ACTIVITY_JSON = '''
    [
        {
            "created_at": "2022-05-20 08:57:13",
            "data": {
                "badge_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/social-badges/026e006f74807cf4063ded57c9f13583.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=4e66feba2951b65ae8697376b6e86468b51c4abe6d1c9d699575559f9b94258d",
                "name": "Alice",
                "user_avatar_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/avatars/10130a69034d88e28d04630b47ce16d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=a6d8c681b78da2c43536f256975693f4e470e556a0912cd97b2ae0b6feeb1bdf"
            },
            "type": 10,
            "universal_link": "https://landing.hooh.zone/users/ba58e9f9-a7f0-46b4-9960-d651c775b61b/badges"
        },
        {
            "created_at": "2022-05-20 08:56:33",
            "data": {
                "badge_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/social-badges/026e006f74807cf4063ded57c9f13583.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=4e66feba2951b65ae8697376b6e86468b51c4abe6d1c9d699575559f9b94258d",
                "name": "test169q8wutgow9aeu9gioyw8uyg",
                "user_avatar_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/hq-content/default_avatars/default_avatar_1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=9948c8a34c4b70cd6d1f0d490c204100cca85879dfa1b5c56c62e4aed258dea4"
            },
            "type": 11,
            "universal_link": "https://landing.hooh.zone/users/fa9c8fde-e84a-4953-9c44-e37e71def81a/badges"
        },
        {
            "created_at": "2022-05-20 08:56:33",
            "data": {
                "signature": "",
                "name": "test16",
                "user_avatar_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/hq-content/default_avatars/default_avatar_1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=9948c8a34c4b70cd6d1f0d490c204100cca85879dfa1b5c56c62e4aed258dea4"
            },
            "type": 6,
            "universal_link": "https://landing.hooh.zone/users/fa9c8fde-e84a-4953-9c44-e37e71def81a"
        },
        {
            "created_at": "2022-05-20 08:50:08",
            "data": {
                "signature": "",
                "name": "test16",
                "user_avatar_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/hq-content/default_avatars/default_avatar_1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=9948c8a34c4b70cd6d1f0d490c204100cca85879dfa1b5c56c62e4aed258dea4"
            },
            "type": 7,
            "universal_link": "https://landing.hooh.zone/users/fa9c8fde-e84a-4953-9c44-e37e71def81a"
        },
        {
            "created_at": "2022-05-20 08:50:06",
            "data": {
                "signature": "",
                "name": "test16",
                "user_avatar_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/hq-content/default_avatars/default_avatar_1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=9948c8a34c4b70cd6d1f0d490c204100cca85879dfa1b5c56c62e4aed258dea4"
            },
            "type": 6,
            "universal_link": "https://landing.hooh.zone/users/fa9c8fde-e84a-4953-9c44-e37e71def81a"
        },
        {
            "created_at": "2022-05-20 08:40:32",
            "data": {
                "post_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/posts/d57abff7ca32d9263f5f2c8d584b43d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=4008a08d7e82b0e89acfe3938a172361e3665b897e2bd3c7e4160eb50020ec9e"
            },
            "type": 4,
            "universal_link": "https://landing.hooh.zone/posts/19036651-e955-4051-8fce-14f64fe0b761"
        },
        {
            "created_at": "2022-05-20 08:37:42",
            "data": {
                "post_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/posts/d57abff7ca32d9263f5f2c8d584b43d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=58f1e7abcdff349656d323c64f8a418d3fe21e718e6c1e6fc263ea9b48e75d65",
                "comment_content": "hi, this is baidu, use \\\\[\\\\] to mention other people!"
            },
            "type": 3,
            "universal_link": "https://landing.hooh.zone/posts/087dca5d-acb6-4228-811e-94fa1ee82a4d"
        },
        {
            "created_at": "2022-05-20 08:36:56",
            "data": {
                "post_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/posts/d57abff7ca32d9263f5f2c8d584b43d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=58f1e7abcdff349656d323c64f8a418d3fe21e718e6c1e6fc263ea9b48e75d65",
                "comment_content": "hi, this is haha, use \\\\[\\\\] to mention other people!"
            },
            "type": 3,
            "universal_link": "https://landing.hooh.zone/posts/087dca5d-acb6-4228-811e-94fa1ee82a4d"
        },
        {
            "created_at": "2022-05-20 08:36:35",
            "data": {
                "post_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/posts/d57abff7ca32d9263f5f2c8d584b43d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=4008a08d7e82b0e89acfe3938a172361e3665b897e2bd3c7e4160eb50020ec9e",
                "comment_content": "hi, this is @Alice, use \\\\[\\\\] to mention other people!"
            },
            "type": 3,
            "universal_link": "https://landing.hooh.zone/posts/087dca5d-acb6-4228-811e-94fa1ee82a4d"
        },
        {
            "created_at": "2022-05-20 08:33:12",
            "data": {
                "post_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/posts/d57abff7ca32d9263f5f2c8d584b43d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=58f1e7abcdff349656d323c64f8a418d3fe21e718e6c1e6fc263ea9b48e75d65",
                "comment_content": "hi, this is Alice, use \\\\[\\\\] to mention other people!"
            },
            "type": 3,
            "universal_link": "https://landing.hooh.zone/posts/087dca5d-acb6-4228-811e-94fa1ee82a4d"
        },
        {
            "created_at": "2022-05-20 08:30:03",
            "data": {
                "post_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/posts/d57abff7ca32d9263f5f2c8d584b43d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=58f1e7abcdff349656d323c64f8a418d3fe21e718e6c1e6fc263ea9b48e75d65"
            },
            "type": 2,
            "universal_link": "https://landing.hooh.zone/posts/087dca5d-acb6-4228-811e-94fa1ee82a4d"
        },
        {
            "created_at": "2022-05-20 08:23:40",
            "data": {
                "template_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/templates/590bf46c875c08f760cd1ac0cff11027.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=cf51a9b31470493b6e911e25d77c2d434803bdd3278a1c752e67840b9442f5e4"
            },
            "type": 1,
            "universal_link": "https://landing.hooh.zone/users/ba58e9f9-a7f0-46b4-9960-d651c775b61b/templates"
        },
        {
            "created_at": "2022-05-20 08:09:27",
            "data": {
                "post_image_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/posts/d57abff7ca32d9263f5f2c8d584b43d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220523T091312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220523%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=58f1e7abcdff349656d323c64f8a418d3fe21e718e6c1e6fc263ea9b48e75d65"
            },
            "type": 0,
            "universal_link": "https://landing.hooh.zone/posts/fc7126d1-a150-4e6b-b6ea-1318b36f0b3d"
        }
    ]
''';
  static const USER_JSON = '''
     {
        "avatar_url": "https://hooh-private.s3.ap-southeast-1.amazonaws.com/user-content/avatars/10130a69034d88e28d04630b47ce16d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220520T085747Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAQS2TD6PIQBMNSPEP%2F20220520%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Signature=cca217ba72c796e3fb22dfab5ae68af152cdf8d12f592564b480007a2e72b254",
        "id": "ba58e9f9-a7f0-46b4-9960-d651c775b61b",
        "name": "Alice"
    }
''';

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
      body: Center(
        child: GridView(
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4, childAspectRatio: 165 / 211),
          children: (json.decode(ACTIVITY_JSON) as List)
              .map((e) => UserActivityView(
                    user: User.fromJson(json.decode(USER_JSON)),
                    activity: UserActivity.fromJson(e),
                  ))
              .toList(),
        ),
      ),
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
