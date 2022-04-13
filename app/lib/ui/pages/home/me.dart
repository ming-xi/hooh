import 'dart:async';

import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pretty_json/pretty_json.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<MePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow.withAlpha(100),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: () async {
                  // 正确的id：network.getUser("283bc4ee-e489-452f-9827-a15946cf9656")

                  //异步请求示例
                  network.requestAsync<User>(network.getUserInfo("4ee-e489-452f-9827-a15946cf9656"), (data) {
                    showDialog(
                        context: context,
                        builder: (e) => AlertDialog(
                              title: const Text("用户"),
                              content: Text(prettyJson(data)),
                            ));
                  }, (error) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(error.message),
                          );
                        });
                  });

                  //合并future示例
                  Future<User> response1 = network.getUserInfo("4ee-e489-452f-9827-a15946cf9656");
                  Future<User> response2 = network.getUserInfo("4ee-e489-452f-9827-a15946cf9656");
                  Future.wait([response1, response2]).then((value) {
                    //所有的请求完成后会回调
                    var value1 = value[0];
                    var value2 = value[1];
                  });
                },
                child: const Text("test user")),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          content: Text("Loading..."),
                        );
                      });
                  network.requestAsync<User>(network.getUserInfo("283bc4ee-e489-452f-9827-a15946cf9656"), (data) async {
                    //如果要获取其他用户的数据，用同步请求。因为已经在一个异步代码块里面了
                    User user = await network.getUserInfo("283bc4ee-e489-452f-9827-a15946cf9656");
                    //user.xxx 直接调用方法
                    //处理完后关闭对话框（方法和回退页面一样，pop掉最上层的东西——对话框）
                    Navigator.of(context).pop();
                  }, (error) {
                    debugPrint(error.toString());
                  });
                },
                child: const Text("test2"))
          ],
        ),
      ),
    );
  }
}
