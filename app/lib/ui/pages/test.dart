import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app/ui/pages/test_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

//test provider and view model
class TestViewModelScreen extends ConsumerStatefulWidget {
  final StateNotifierProviderFamily<TestPageViewModel, TestPageModelState, int> postsProvider =
      StateNotifierProvider.family<TestPageViewModel, TestPageModelState, int>((ref, width) => TestPageViewModel(TestPageModelState.init(width, true)));

  TestViewModelScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestViewModelScreen> {
  @override
  Widget build(BuildContext context) {
    StateNotifierProvider<TestPageViewModel, TestPageModelState> provider = widget.postsProvider(1);
    TestPageModelState modelState = ref.watch(provider);
    TestPageViewModel viewModel = ref.watch(provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
      ),
      body: Center(
        child: Text(modelState.keyword),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text(modelState.pageIndex.toString()),
        onPressed: () {
          viewModel.update(modelState.copyWith(pageIndex: modelState.pageIndex + 1, keyword: Random().nextInt(1000).toString()));
        },
      ),
    );
  }
}

//测试png着色
class TestTintScreen extends ConsumerStatefulWidget {
  final StateProvider<double> hue1Provider = StateProvider(
    (ref) {
      return 0.0;
    },
  );
  final StateProvider<double> hue2Provider = StateProvider(
    (ref) {
      return 0.0;
    },
  );

  TestTintScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestTintPageState();
}

class _TestTintPageState extends ConsumerState<TestTintScreen> {
  Uint8List? imageFileBytes1;
  Uint8List? imageFileBytes2;

  @override
  void initState() {
    super.initState();
    rootBundle.load("assets/images/1.png").then((value) {
      //测试用，正式不用setState
      setState(() {
        imageFileBytes1 = value.buffer.asUint8List();
      debugPrint("load asset1 ${imageFileBytes1!.length}");
      });
    });
    rootBundle.load("assets/images/2.png").then((value) {
      //测试用，正式不用setState
      setState(() {
        imageFileBytes2 = value.buffer.asUint8List();
      debugPrint("load asset2 ${imageFileBytes2!.length}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build");
    var hue1 = ref.watch(widget.hue1Provider.state).state;
    var hue2 = ref.watch(widget.hue2Provider.state).state;
    return Scaffold(
      appBar: AppBar(title: const Text("tint")),
      body: Container(
        color: Colors.black.withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: 200,
                  height: 225,
                  child: Container(
                    color: Colors.white,
                    child: Stack(children: [
                      Image.asset(
                        'assets/images/3.png',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.none,
                        width: 220,
                        height: 225,
                      ),
                      imageFileBytes2 != null
                          ? Image.memory(
                              getImageBytes(imageFileBytes2!,hue2),
                              gaplessPlayback: true,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.none,
                              width: 220,
                              height: 225,
                            )
                          : Container(),
                      imageFileBytes1 != null
                          ? Image.memory(
                              getImageBytes(imageFileBytes1!,hue1),
                              gaplessPlayback: true,
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.none,
                              width: 220,
                              height: 225,
                            )
                          : Container()
                    ]),
                  ),
                ),
              ),
              Slider(
                  value: hue1,
                  min: 0,
                  max: 360,
                  onChanged: (newValue) {
                    ref.read(widget.hue1Provider.state).state = newValue;
                  }),
              Slider(
                  value: hue2,
                  min: 0,
                  max: 360,
                  onChanged: (newValue) {
                    ref.read(widget.hue2Provider.state).state = newValue;
                  })
            ],
          ),
        ),
      ),
    );
  }

  Uint8List getImageBytes(Uint8List fileBytes,double hue) {
    img.Image? image = img.decodePng(fileBytes);
    Uint32List pixels = image!.data;
    for (int i = 0; i < pixels.length; i++) {
      int pixel = pixels[i];
      Color color = Color(pixel);
      int a = color.alpha;
      int b = color.red;
      int g = color.green;
      int r = color.blue;
      color = Color.fromARGB(a, r, g, b);
      HSLColor hslColor = HSLColor.fromColor(color);
      double hue2 = hslColor.hue + hue;
      if (hue2 > 360) {
        hue2 -= 360;
      }
      hslColor = hslColor.withHue(hue2);
      color = hslColor.toColor();
      pixels[i] = Color.fromARGB(color.alpha, color.blue, color.green, color.red).value;
    }
    return Uint8List.fromList(img.encodePng(image));
  }

  // 从asset复制文件
  // Future<File> copyAsset(String assetPath) async {
  //   debugPrint("copyAsset");
  //   final Directory docDir = await getApplicationSupportDirectory();
  //   final String localPath = docDir.path;
  //   File file = File('$localPath/${assetPath.split('/').last}');
  //   final imageBytes = await rootBundle.load(assetPath);
  //   final buffer = imageBytes.buffer;
  //   await file.writeAsBytes(buffer.asUint8List(imageBytes.offsetInBytes, imageBytes.lengthInBytes));
  //   return file;
  // }
}
