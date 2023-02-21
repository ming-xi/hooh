import 'dart:typed_data';
import 'package:app/global.dart';
import 'package:app/ui/pages/creation/publish_post_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/app_link.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/file_utils.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/post.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';

class ShareScreen extends ConsumerStatefulWidget {
  // static const LANDING_PAGE_HOST = "www.hooh.zone";
  static const LANDING_PAGE_HOST = "app.hooh.zone";
  static const LANDING_PAGE_HOST_STAGING = "stg-app.hooh.zone";

  // static const LANDING_PAGE_PATH = "/site";
  static const LANDING_PAGE_PATH = "placeholder";
  static const LANDING_PAGE_REAL_PATH = "/#/landing";
  static const LANDING_PAGE_URL_PARAM_NAME = "app_link";

  static const SCENE_USER_CARD = 0;
  static const SCENE_POST_IMAGE = 1;
  static const SCENE_POST_POSTER = 2;
  static const _USER_CARD_SIZE = Size(335, 460);
  static const _POST_IMAGE_SIZE = Size(335, 335);
  static const _POST_POSTER_SIZE = Size(335, 502);
  final int scene;
  final Post? post;

  const ShareScreen({
    required this.scene,
    this.post,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  File? userQrcodeFile;
  File? screenshotFile;

  late final Size contentSize;

  @override
  void initState() {
    super.initState();
    switch (widget.scene) {
      case ShareScreen.SCENE_POST_IMAGE:
        {
          contentSize = ShareScreen._POST_IMAGE_SIZE;
          break;
        }
      case ShareScreen.SCENE_POST_POSTER:
        {
          contentSize = ShareScreen._POST_POSTER_SIZE;
          break;
        }
      case ShareScreen.SCENE_USER_CARD:
      default:
        {
          contentSize = ShareScreen._USER_CARD_SIZE;
        }
    }
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.forward();
      if (widget.scene == ShareScreen.SCENE_USER_CARD) {
        User user = ref.read(globalUserInfoProvider)!;
        // Uri uri = Uri(scheme: "https",host: ShareScreen.LANDING_PAGE_HOST,fragment: ShareScreen.LANDING_PAGE_SLASH_PATH,queryParameters: {ShareScreen.LANDING_PAGE_URL_PARAM_NAME: getUserAppLink(user.id)});
        String authority = network.serverType == Network.TYPE_PRODUCTION ? ShareScreen.LANDING_PAGE_HOST : ShareScreen.LANDING_PAGE_HOST_STAGING;
        Uri uri = Uri.https(authority, ShareScreen.LANDING_PAGE_PATH,
            {ShareScreen.LANDING_PAGE_URL_PARAM_NAME: getUserAppLink(user.id)});
        String urlString = uri.toString();
        urlString = urlString.replaceAll(
            ShareScreen.LANDING_PAGE_PATH, ShareScreen.LANDING_PAGE_REAL_PATH);
        debugPrint("share url=$urlString");
        File file = await FileUtil.generateQrCodeSvgFile(urlString, 200);
        setState(() {
          userQrcodeFile = file;
        });
      }
      Future.delayed(
        Duration(milliseconds: 250),
        () async {
          showHoohDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return LoadingDialog(LoadingDialogController());
              });
          _shareImage(await _saveScreenshot(
              context, contentSize.width, contentSize.height));
          Navigator.of(context).pop();
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var old = buildBackground(
    //       child: Stack(
    //     children: [
    //       Positioned.fill(
    //         child: AnimatedBuilder(
    //           animation: _controller,
    //           builder: (builderContext, child) {
    //             return Opacity(
    //               opacity: 1 * _controller.drive(CurveTween(curve: GENERAL_CURVE)).value,
    //               child: child,
    //             );
    //           },
    //           child: CustomScrollView(
    //             slivers: [
    //               SliverFillRemaining(
    //                 hasScrollBody: false,
    //                 child: Padding(
    //                   padding: const EdgeInsets.symmetric(horizontal: 20),
    //                   child: buildShareContentView(),
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //           left: 0,
    //           right: 0,
    //           bottom: 0,
    //           child: AnimatedBuilder(
    //             animation: _controller,
    //             builder: (builderContext, child) {
    //               return Transform.translate(
    //                 offset: Offset(0, (1 - _controller.drive(CurveTween(curve: GENERAL_CURVE)).value) * 200),
    //                 child: child,
    //               );
    //             },
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 20),
    //               child: buildBottomMenu(),
    //             ),
    //           ))
    //     ],
    //   ));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(),
    );
  }

  Widget buildScreenshotTarget() {
    switch (widget.scene) {
      case ShareScreen.SCENE_POST_POSTER:
        {
          return Container();
        }
      case ShareScreen.SCENE_POST_IMAGE:
        {
          return buildPostImage();
        }
      case ShareScreen.SCENE_USER_CARD:
      default:
        {
          return buildUserCard();
        }
    }
  }

  // Widget buildShareContentView() {
  //   double headerHeight = 0;
  //   double footerHeight = 0;
  //   Widget content;
  //   switch (widget.scene) {
  //     case ShareScreen.SCENE_POST_POSTER:
  //       {
  //         content = Container();
  //         break;
  //       }
  //     case ShareScreen.SCENE_POST_IMAGE:
  //       {
  //         headerHeight = 181;
  //         footerHeight = 296;
  //         content = buildPostImage();
  //         break;
  //       }
  //     case ShareScreen.SCENE_USER_CARD:
  //     default:
  //       {
  //         headerHeight = 117;
  //         footerHeight = 245;
  //         content = buildUserCard();
  //       }
  //   }
  //   return Column(
  //     mainAxisSize: MainAxisSize.max,
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       SizedBox(
  //         height: headerHeight,
  //       ),
  //       Container(
  //         decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: Offset(0, 8), blurRadius: 24)]),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(24),
  //           child: content,
  //         ),
  //       ),
  //       SizedBox(
  //         height: footerHeight,
  //       ),
  //     ],
  //   );
  // }

  // AnimatedBuilder buildBackground({required Widget child}) {
  //   return AnimatedBuilder(
  //     animation: _controller,
  //     builder: (builderContext, child) {
  //       // debugPrint("_controller.value=${_controller.value}");
  //       return Blur(
  //         blur: 6 * _controller.value,
  //         blurColor: designColors.dark_03.auto(ref).withOpacity(_controller.value),
  //         colorOpacity: 0.4 * _controller.value,
  //         // overlay: Opacity(opacity: 1 * _controller.value, child: child!),
  //         overlay: child,
  //         child: Container(),
  //       );
  //     },
  //     child: child,
  //   );
  // }

  // Widget buildBottomMenu() {
  //   return Container(
  //     decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: Offset(0, 0), blurRadius: 24)]),
  //     child: ClipRRect(
  //         borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
  //         child: Container(
  //           color: designColors.light_01.auto(ref),
  //           child: Material(
  //             type: MaterialType.transparency,
  //             child: SafeArea(
  //               top: false,
  //               child: Padding(
  //                 padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.stretch,
  //                   children: [
  //                     SizedBox(
  //                       height: 36,
  //                       child: CustomScrollView(
  //                         scrollDirection: Axis.horizontal,
  //                         slivers: [
  //                           SliverFillRemaining(
  //                             child: Row(
  //                               mainAxisSize: MainAxisSize.min,
  //                               crossAxisAlignment: CrossAxisAlignment.center,
  //                               children: [
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(top: 4),
  //                                   child: Text(
  //                                     globalLocalizations.share_card_share_to,
  //                                     style: TextStyle(fontSize: 12, color: designColors.light_06.auto(ref)),
  //                                   ),
  //                                 ),
  //                                 SizedBox(
  //                                   width: 8,
  //                                 ),
  //                                 IconButton(
  //                                     onPressed: () async {
  //                                       showHoohDialog(
  //                                           context: context,
  //                                           barrierDismissible: false,
  //                                           builder: (context) {
  //                                             return LoadingDialog(LoadingDialogController());
  //                                           });
  //                                       _saveImage(await _saveScreenshot(context, contentSize.width, contentSize.height));
  //                                       Navigator.of(context).pop();
  //                                       showSnackBar(context, globalLocalizations.save_share_card_success);
  //                                     },
  //                                     icon: HoohIcon(
  //                                       "assets/images/icon_download.svg",
  //                                       width: 24,
  //                                       height: 24,
  //                                       color: designColors.dark_01.auto(ref),
  //                                     )),
  //                                 IconButton(
  //                                     onPressed: () async {
  //                                       showHoohDialog(
  //                                           context: context,
  //                                           barrierDismissible: false,
  //                                           builder: (context) {
  //                                             return LoadingDialog(LoadingDialogController());
  //                                           });
  //                                       _shareImage(await _saveScreenshot(context, contentSize.width, contentSize.height));
  //                                       Navigator.of(context).pop();
  //                                     },
  //                                     icon: HoohIcon(
  //                                       "assets/images/icon_more.svg",
  //                                       width: 24,
  //                                       height: 24,
  //                                       color: designColors.dark_01.auto(ref),
  //                                     )),
  //                               ],
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: 24,
  //                     ),
  //                     MainStyles.outlinedTextButton(ref, globalLocalizations.common_cancel, () {
  //                       _close();
  //                     })
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         )),
  //   );
  // }

  Future<void> _saveImage(File file) async {
    await FileUtil.saveImageToGallery(file);
  }

  void _shareImage(File file) {
    final box = context.findRenderObject() as RenderBox?;
    Rect origin = box!.localToGlobal(Offset.zero) & box.size;
    debugPrint("origin=${origin.toString()}");
    Share.shareFiles(
      [file.path],
      mimeTypes: ["image/*"],
      sharePositionOrigin: origin,
    ).then((value) {
      Navigator.of(
        context,
      ).pop();
    });
  }

  Widget buildPostImage() {
    return HoohImage(
      imageUrl: widget.post!.images[0].imageUrl,
      // width: 335,
      // height: 335,
    );
  }

  Widget buildUserCard() {
    User user = ref.read(globalUserInfoProvider)!;
    return SizedBox(
      width: 335,
      height: 460,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/figure_share_card.png",
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 20,
              child: Center(
                child: HoohImage(
                  imageUrl: user.badgeImageUrl!,
                  isBadge: true,
                  width: 120,
                  height: 135,
                ),
              )),
          Positioned(
              right: 98,
              top: 111,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  padding: EdgeInsets.all(1),
                  child: ClipOval(
                    child: HoohImage(
                      imageUrl: user.avatarUrl!,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              )),
          Positioned(
              left: 0,
              right: 0,
              top: 170,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.dark_01.light),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "@${user.username!}",
                    style: TextStyle(fontSize: 12, color: designColors.light_06.light),
                  ),
                ],
              )),
          Positioned(
              left: 0,
              right: 0,
              bottom: 54,
              child: Center(
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: Container(
                    decoration: BoxDecoration(
                        color: designColors.light_01.light,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: designColors.light_06.light, width: 1)),
                    child: userQrcodeFile == null
                        ? Container()
                        : Center(
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: SvgPicture.file(
                                userQrcodeFile!,
                              ),
                            ),
                          ),
                  ),
                ),
              )),
        ],
      ),
    );
    // return Container(
    //   decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: Offset(0, 8), blurRadius: 24)]),
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(24),
    //     child: stack,
    //   ),
    // );
  }

  Future<File> _saveScreenshot(BuildContext context, double width, double height) async {
    if (screenshotFile != null) {
      return screenshotFile!;
    }
    WidgetsBinding? binding = WidgetsBinding.instance;
    double devicePixelRatio = binding.window.devicePixelRatio;
    double screenWidth = MediaQuery.of(context).size.width;
    double ratio = PublishPostScreenViewModel.OUTPUT_IMAGE_SIZE /
        (screenWidth / devicePixelRatio);
    Widget widget = ProviderScope(
      child: SizedBox(
        width: width,
        height: height,
        child: buildScreenshotTarget(),
      ),
    );
    ScreenshotController screenshotController = ScreenshotController();
    // Uint8List fileBytes = await screenshotController.captureFromWidget(widget, pixelRatio: ratio);
    Uint8List fileBytes = await screenshotController.captureFromWidget(widget,
        pixelRatio: PublishPostScreenViewModel.OUTPUT_IMAGE_SIZE / width);
    // img.Image image = img.decodeImage(fileBytes)!;
    img.Image image = (await compute(img.decodeImage, fileBytes))!;
    debugPrint(
        "screenWidth=$screenWidth size=${width}x$height ratio=$devicePixelRatio image_size=${image.width}x${image.height}");
    // List<int> jpgBytes = img.encodeJpg(image, quality: 80);
    List<int> jpgBytes = await compute(img.encodeJpg, image);
    String name = md5.convert(jpgBytes).toString();
    // var decodeJpg = img.decodePng(bytes);
    // debugPrint("decodeJpg ${decodeJpg!.width} x ${decodeJpg.height}");
    Directory saveDir = await getApplicationDocumentsDirectory();
    File file = File('${saveDir.path}/$name.jpg');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsBytesSync(jpgBytes, flush: true);
    screenshotFile = file;
    return file;
  }

  void _close() {
    _controller.addStatusListener((state) {
      debugPrint("state=$state");
      if (state == AnimationStatus.dismissed) {
        Navigator.of(
          context,
        ).pop();
      }
    });
    _controller.reverse();
  }
}
