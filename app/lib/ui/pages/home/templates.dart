import 'dart:async';
import 'dart:io';

import 'package:app/extensions/extensions.dart';
import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/creation/template_adjust.dart';
import 'package:app/ui/pages/gallery/search.dart';
import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'templates_view_model.dart';

class GalleryPage extends ConsumerStatefulWidget {
  final StateNotifierProvider<TemplatesPageViewModel, TemplatesPageModelState> templatesProvider = StateNotifierProvider((ref) {
    return TemplatesPageViewModel(TemplatesPageModelState.init());
  });

  GalleryPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _imageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build page");
    final ScrollController _controller = ScrollController();
    int imageWidth = MediaQuery.of(context).size.width ~/ 3;

    TemplatesPageModelState modelState = ref.watch(widget.templatesProvider);
    TemplatesPageViewModel model = ref.read(widget.templatesProvider.notifier);

    double safePadding = MediaQuery.of(context).padding.top;
    debugPrint("safePadding=$safePadding");
    double padding = 16.0;
    double iconSize = 24.0;
    double listHeight = 40.0;
    double totalHeight = padding * 4 + iconSize + listHeight;
    totalHeight += padding;
    var searchBar = buildSearchBar(context, iconSize, padding);
    var categoryBar = buildTags(padding, listHeight, _controller, model, modelState);
    Widget listWidget = modelState.selectedTag == null ? Container() : buildListWidget(model, modelState, imageWidth, totalHeight + safePadding);
    return Scaffold(
      floatingActionButton: SafeArea(
        minimum: EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.extended(
          label: Container(
            constraints: BoxConstraints(minHeight: 64, minWidth: 128),
            child: Center(
                child: Text(
              "Upload",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            )),
            decoration: MainStyles.gradientButtonDecoration(cornerRadius: 22),
          ),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
          // child: Text("Upload"),
          elevation: 0,
          isExtended: true,
          extendedPadding: EdgeInsets.all(0),
          onPressed: () {
            if (!(preferences.getBool(Preferences.KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED) ?? false)) {
              showUploadDialog();
              return;
            } else {
              _showLocalOptionActionSheet();
            }
          },
          backgroundColor: Colors.transparent,
        ),
      ),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(totalHeight),
        child: Builder(builder: (context) {
          return AppBar(
                  toolbarHeight: padding * 5 + iconSize,
                  elevation: 0,
                  title: searchBar,
                  titleSpacing: 0,
                  bottom: PreferredSize(preferredSize: Size.fromHeight(listHeight), child: categoryBar),
                  backgroundColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.dark)
              .frosted(
            blur: 10,
            frostColor: designColors.light_01.auto(ref),
            frostOpacity: 0.9,
          );
        }),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: listWidget,
      ),
    );
  }

  Widget buildListWidget(TemplatesPageViewModel viewModel, TemplatesPageModelState modelState, int width, double totalHeight) {
    Widget listWidget;

    listWidget = SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: MaterialClassicHeader(
        offset: totalHeight,
        color: designColors.feiyu_blue.auto(ref),
      ),
      onRefresh: () async {
        viewModel.getImageList((state) {
          debugPrint("refresh state=$state");
          _refreshController.refreshCompleted();
        });
      },
      onLoading: () async {
        viewModel.getImageList((state) {
          if (state == PageState.noMore) {
            _refreshController.loadNoData();
            debugPrint("load no more state=$state");
          } else {
            _refreshController.loadComplete();
            debugPrint("load complete state=$state");
          }
        }, isRefresh: false);
      },
      controller: _refreshController,
      child: GridView.builder(
        controller: _imageScrollController,
        padding: EdgeInsets.fromLTRB(16, totalHeight, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //横轴元素个数
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            //子组件宽高长度比例
            childAspectRatio: 1.0),
        itemCount: modelState.templates.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return GestureDetector(
              child: const AddLocalImageView(),
              onTap: () {
                _galleryItemTouched(index);
              },
            );
          } else {
            TemplateViewSetting viewSetting = TemplateView.generateViewSetting(TemplateView.SCENE_GALLERY_HOME);
            viewSetting.buttons[TemplateView.EDGE_BUTTON_TYPE_FAVORITE]!.onPress = (newState) {
              debugPrint("newState=$newState index=${index - 1}");
              viewModel.setFavorite(index - 1, newState);
            };
            Template template = modelState.templates[index - 1];
            return GestureDetector(
              onTap: () {
                _galleryItemTouched(index);
              },
              child: TemplateView(PostImageSetting.withTemplate(template), viewSetting: viewSetting, template: template),
            );
          }
        },
      ),
    );

    return listWidget;
  }

  Widget buildTags(double padding, double listHeight, ScrollController _controller, TemplatesPageViewModel viewModel, TemplatesPageModelState modelState) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: SizedBox(
        height: listHeight,
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // TemplateTagItem selectedTag;
                for (var item in modelState.tags) {
                  item.selected = false;
                }
                modelState.tags[index].selected = true;
                // selectedTag = modelState.tags[index];
                // 因为categories其实还是原来的list，所以给state赋值无效。所以要构建一个新的list赋值，有3种写法：
                // #1
                // List<TemplateTagItemItem> newList = [];
                // newList.addAll(categories);
                // ref.read(galleryCategoriesProvider.state).state = newList;

                // #2 这个叫联什么什么写法，就是两个点，代表要对这个对象进行后面的操作
                // ref.read(galleryCategoriesProvider.state).state = []..addAll(categories);

                // #3 dart把#2优化成了3个点的，叫spread，一个意思，语法糖
                viewModel.updateState(modelState.copyWith(tags: [...modelState.tags]));
                viewModel.getImageList((state) => null);
                _refreshController.resetNoData();
                _imageScrollController.jumpTo(0);
                // _controller.animateTo(125, duration: Duration(milliseconds: 250), curve: Curves.ease);
              },
              child: TagItemView(modelState.tags[index]),
            );
          },
          itemCount: modelState.tags.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget buildSearchBar(BuildContext context, double iconSize, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding * 2, padding, padding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: const Color(0xFFEAEAEA),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) {
              return GallerySearchScreen();
            }, transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            }));
          },
          child: Row(
            children: [
              HoohIcon('assets/images/icon_search.svg', height: iconSize, width: iconSize),
              SizedBox(width: padding),
              const Expanded(
                  child: Text(
                'search',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF707070)),
              ))
            ],
          ),
        ),
        padding: EdgeInsets.all(padding),
      ),
    );
  }

  Future<void> _galleryItemTouched(int index) async {
    if (index == 0) {
      debugPrint("插入图片");
      // FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowCompression: false);
      // if (result != null) {
      //   File file = File(result.files.single.path!);
      //
      // }

      if (!(preferences.getBool(Preferences.KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED) ?? false)) {
        showUploadDialog();
        return;
      } else {
        _showLocalOptionActionSheet();
      }
    } else {
      debugPrint("进入做图");
    }
  }

  Future<void> _showLocalOptionActionSheet() async {
    User? user = ref.read(globalUserInfoProvider.state).state;
    if (user == null) {
      Toast.showSnackBar(context, "must login first");
      return;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      CupertinoActionSheet actionSheet = CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              debugPrint("camera");
              Navigator.pop(context);
              openImagePicker(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Gallery'),
            onPressed: () {
              debugPrint("gallery");
              Navigator.pop(context);
              openImagePicker(ImageSource.gallery);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            debugPrint("cancel");
            Navigator.pop(context);
          },
        ),
      );

      /// To display an actionSheet
      showCupertinoModalPopup(context: context, builder: (context) => actionSheet);
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) => Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  openImagePicker(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  openImagePicker(ImageSource.gallery);
                },
              ),
            ],
          ));
    }
  }

  /// Open image picker
  void openImagePicker(source) async {
    // showLoader();
    final XFile? pickedFile = await ImagePicker().pickImage(source: source, maxWidth: 1920, maxHeight: 1920);
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings()
      ],
    );
    if (croppedFile != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AdjustTemplatePositionScreen(File(croppedFile.path))));
    }
  }

  void showUploadDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Consumer(
            builder: (context, ref, child) {
              TemplatesPageModelState modelState = ref.watch(widget.templatesProvider);
              TemplatesPageViewModel model = ref.read(widget.templatesProvider.notifier);
              return AlertDialog(
                insetPadding: EdgeInsets.all(20),
                title: Text(
                  "Upload material description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                titlePadding: EdgeInsets.only(top: 24, left: 24, right: 24),
                contentPadding: EdgeInsets.all(16),
                content: Builder(builder: (context) {
                  double screenHeight = MediaQuery.of(context).size.height;
                  double screenWidth = MediaQuery.of(context).size.width;

                  return SizedBox(
                    width: screenWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            height: screenHeight / 4,
                            child: CustomScrollView(
                              slivers: [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Text(
                                    """1. During the image uploading process, the image needs to be preprocessed
2. Fail to upload a material to get x ore
3. After the material is approved, it will appear in the gallery.
4. Additional rewards for being successfully cited""",
                                    style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 4,
                            ),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: modelState.agreementChecked,
                                onChanged: (value) {
                                  model.setAgreementChecked(value!);
                                },
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Don't prompt next time",
                              style: TextStyle(color: designColors.dark_01.auto(ref), fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: MainStyles.outlinedTextButton(ref, "Cancel", () {
                                Navigator.pop(context);
                              }),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: MainStyles.gradientButton(ref, "Confirm", () {
                                preferences.putBool(Preferences.KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED, modelState.agreementChecked);
                                Navigator.pop(context);
                                _showLocalOptionActionSheet();
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          );
        });
  }
}

class TagItemView extends ConsumerWidget {
  final TemplateTagItem item;

  const TagItemView(
    this.item, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: item.selected ? designColors.feiyu_yellow.auto(ref) : Colors.transparent,
      ),
      height: 40,
      constraints: BoxConstraints(minWidth: 72),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
          child: Text(item.tag,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: item.selected ? Colors.white : designColors.light_06.auto(ref)))),
    );
  }
}

class AddLocalImageView extends ConsumerStatefulWidget {
  const AddLocalImageView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AddLocalImageViewState();
}

class _AddLocalImageViewState extends ConsumerState<AddLocalImageView> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0167F9),
      )),
      Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.add,
            color: Colors.white,
            size: 36,
          ),
          Text(
            "Insert picture",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          )
        ],
      )),
      // Image.asset('assets/images/test_2.png'),
      // Image.asset('assets/images/test_3.png',colorBlendMode: BlendMode.srcATop, color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6)),
      // Image.asset('assets/images/test_1.png',colorBlendMode: BlendMode.srcATop, color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6)),
    ]);
  }
}

