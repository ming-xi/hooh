import 'dart:async';

import 'package:app/global.dart';
import 'package:app/ui/pages/creation/edit_post.dart';
import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/ui/pages/creation/template_text_setting.dart';
import 'package:app/ui/pages/gallery/search.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/ui/widgets/template_compose_view.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:blur/blur.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import 'templates_view_model.dart';

final StateNotifierProvider<TemplatesPageViewModel, TemplatesPageModelState> homeTemplatesProvider = StateNotifierProvider((ref) {
  return TemplatesPageViewModel(TemplatesPageModelState.init());
});

class GalleryPage extends ConsumerStatefulWidget {
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
    // important! make it change text when locale changes
    ref.watch(globalLocaleProvider);
    int imageWidth = MediaQuery.of(context).size.width ~/ 3;
    debugPrint("page context=$context");
    TemplatesPageModelState modelState = ref.watch(homeTemplatesProvider);
    TemplatesPageViewModel model = ref.read(homeTemplatesProvider.notifier);

    double safePadding = MediaQuery.of(context).padding.top;
    // double padding = 16.0;
    double padding = 8;
    double iconSize = 24.0;
    double listHeight = 40.0;
    double totalHeight = padding * 4 + iconSize + listHeight;
    // totalHeight += padding;
    // totalHeight += padding*4;
    var searchBar = buildSearchBar(context, iconSize, padding);
    var categoryBar = buildTags(padding, listHeight, ScrollController(), model, modelState);
    Widget listWidget = modelState.selectedTag == null ? Container() : buildListWidget(model, modelState, imageWidth, totalHeight + safePadding + padding * 2);

    double buttonMarginBottom = 12;
    double labelMarginBottom = buttonMarginBottom + 48;
    double labelMarginRight = 22;
    double arrowMarginRight = labelMarginRight + 12;
    double arrowMarginBottom = labelMarginBottom - 8;
    return Scaffold(
      // floatingActionButton: SafeArea(
      //   minimum: EdgeInsets.only(bottom: 100),
      //   child: FloatingActionButton.extended(
      //     label: Container(
      //       constraints: BoxConstraints(minHeight: 64, minWidth: 128),
      //       child: Center(
      //           child: Text(
      //         globalLocalizations.templates_title,
      //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      //       )),
      //       decoration: MainStyles.gradientButtonDecoration(ref, cornerRadius: 22),
      //     ),
      //     // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
      //     // child: Text("Upload"),
      //     elevation: 0,
      //     isExtended: true,
      //     extendedPadding: EdgeInsets.all(0),
      //     onPressed: () {
      //       if (!(preferences.getBool(Preferences.KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED) ?? false)) {
      //         showUploadDialog();
      //         return;
      //       } else {
      //         _showLocalOptionActionSheet();
      //       }
      //     },
      //     backgroundColor: Colors.transparent,
      //   ),
      // ),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(totalHeight),
        child: Builder(builder: (context) {
          return AppBar(
              title: Text(globalLocalizations.templates_title),
                  bottom: PreferredSize(preferredSize: Size.fromHeight(listHeight), child: categoryBar),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  systemOverlayStyle: SystemUiOverlayStyle.dark)
              .frosted(
            blur: 10,
            frostColor: designColors.light_01.auto(ref),
            frostOpacity: 0.9,
          );
          // return AppBar(
          //         toolbarHeight: padding * 5 + iconSize,
          //         elevation: 0,
          //         title: searchBar,
          //         titleSpacing: 0,
          //         bottom: PreferredSize(preferredSize: Size.fromHeight(listHeight), child: categoryBar),
          //         backgroundColor: Colors.transparent,
          //         systemOverlayStyle: SystemUiOverlayStyle.dark)
          //     .frosted(
          //   blur: 10,
          //   frostColor: designColors.light_01.auto(ref),
          //   frostOpacity: 0.9,
          // );
        }),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: listWidget),
            Positioned(
                right: 0,
                bottom: buttonMarginBottom,
                child: SafeArea(
                  child: Material(
                    color: designColors.light_00.auto(ref),
                    type: MaterialType.transparency,
                    child: Ink(
                      width: 160,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: MainStyles.buttonGradient(ref, enabled: true),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
                        onTap: () {
                          User? user = ref.read(globalUserInfoProvider);
                          if (user == null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
                            return;
                          }
                          if (!(preferences.getBool(Preferences.KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED) ?? false)) {
                            showUploadDialog();
                            // return;
                          } else {
                            showSelectLocalImageActionSheet(
                                context: context,
                                adjustTemplateImage: true,
                                ref: ref,
                                onSelected: (file) {
                                  if (file == null) {
                                    return;
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TemplateTextSettingScreen(
                                                imageFile: file,
                                              )));
                                });
                          }
                        },
                        child: Center(
                            child: Text(
                          globalLocalizations.templates_upload_button,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                )),
            Positioned(
                right: labelMarginRight,
                bottom: labelMarginBottom,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 24,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(color: designColors.light_01.auto(ref), borderRadius: BorderRadius.circular(10.5)),
                        child: Center(
                          child: Text(
                            globalLocalizations.templates_reward,
                            style: TextStyle(fontSize: 16, color: designColors.orange.auto(ref), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            Positioned(
                bottom: arrowMarginBottom,
                right: arrowMarginRight,
                child: SafeArea(
                  child: HoohIcon(
                    'assets/images/figure_template_reward_arrow.svg',
                    color: designColors.light_01.auto(ref),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget buildListWidget(TemplatesPageViewModel model, TemplatesPageModelState modelState, int width, double totalHeight) {
    Widget listWidget;
    listWidget = SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: MainStyles.getRefresherHeader(ref, offset: totalHeight),
      onRefresh: () async {
        model.getImageList((state) {
          // debugPrint("refresh state=$state");
          _refreshController.refreshCompleted();
        });
      },
      onLoading: () async {
        model.getImageList((state) {
          if (state == PageState.noMore) {
            _refreshController.loadNoData();
            // debugPrint("load no more state=$state");
          } else {
            _refreshController.loadComplete();
            // debugPrint("load complete state=$state");
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
              User? user = ref.read(globalUserInfoProvider);
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
                return;
              }
              model.setFavorite(index - 1, newState);
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

  Widget buildTags(double padding, double listHeight, ScrollController _controller, TemplatesPageViewModel model, TemplatesPageModelState modelState) {
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
                // // TemplateTagItem selectedTag;
                // for (var item in modelState.tags) {
                //   item.selected = false;
                // }
                // modelState.tags[index].selected = true;
                // // selectedTag = modelState.tags[index];
                // // 因为categories其实还是原来的list，所以给state赋值无效。所以要构建一个新的list赋值，有3种写法：
                // // #1
                // // List<TemplateTagItemItem> newList = [];
                // // newList.addAll(categories);
                // // ref.read(galleryCategoriesProvider.state).state = newList;
                //
                // // #2 这个叫联什么什么写法，就是两个点，代表要对这个对象进行后面的操作
                // // ref.read(galleryCategoriesProvider.state).state = []..addAll(categories);
                //
                // // #3 dart把#2优化成了3个点的，叫spread，一个意思，语法糖
                // viewModel.updateState(modelState.copyWith(tags: [...modelState.tags]));
                // viewModel.getImageList((state) => null);
                model.setSelectedTag(index);
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
          color: designColors.light_02.auto(ref),
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
              HoohIcon(
                'assets/images/icon_search.svg',
                height: iconSize,
                width: iconSize,
                color: designColors.dark_01.auto(ref),
              ),
              SizedBox(width: padding),
              Expanded(
                  child: Text(
                globalLocalizations.templates_search,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: designColors.light_06.auto(ref)),
              ))
            ],
          ),
        ),
        padding: EdgeInsets.all(padding),
      ),
    );
  }

  Future<void> _galleryItemTouched(int index) async {
    User? user = ref.read(globalUserInfoProvider);
    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
      return;
    }
    if (index == 0) {
      if (!(preferences.getBool(Preferences.KEY_USE_LOCAL_IMAGE_NO_REWARDS_CHECKED) ?? false)) {
        showUseLocalImageNoRewardsDialog();
        return;
      } else {
        pickLocalImageForCreation();
      }

      // if (!(preferences.getBool(Preferences.KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED) ?? false)) {
      //   showUploadDialog();
      //   return;
      // } else {
      //   showSelectLocalImageActionSheet(context, ref, (file) {
      //     Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => TemplateTextSettingScreen(
      //                   imageFile: file,
      //                 )));
      //   });
      // }
    } else {
      TemplatesPageModelState modelState = ref.watch(homeTemplatesProvider);
      Template template = modelState.templates[index - 1];
      network.requestAsync<Template>(network.getTemplateInfo(template.id), (data) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(setting: PostImageSetting.withTemplate(data, text: ""))));
      }, (error) {
        if (error.errorCode == Constants.RESOURCE_NOT_FOUND) {
          showDialog(
              context: context,
              builder: (popContext) => AlertDialog(
                    title: Text(globalLocalizations.error_view_template_not_found),
                  ));
        } else {
          showCommonRequestErrorDialog(ref, context, error);
        }
      });
      // Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostScreen(setting: PostImageSetting.withTemplate(template, text: ""))));
    }
  }

  void pickLocalImageForCreation() {
    return showSelectLocalImageActionSheet(
        context: context,
        ref: ref,
        adjustTemplateImage: true,
        onSelected: (file) {
          if (file == null) {
            return;
          }
          Color textColor = isImageDarkColor(file.readAsBytesSync()) ? Colors.white : Colors.black;
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return EditPostScreen(setting: PostImageSetting.withLocalFile(file, textColor, text: ""));
          }));
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => EditPostScreen(setting: PostImageSetting.withLocalFile(file, Colors.white, text: ""))));
        });
  }

  void showUploadDialog() {
    TemplatesPageModelState modelState = ref.watch(homeTemplatesProvider);
    TemplatesPageViewModel model = ref.read(homeTemplatesProvider.notifier);
    network.getFeeInfo().then((response) {
      int createTemplateReward = response.createTemplateReward;
      _showDialogWithCheckBox(
          title: globalLocalizations.templates_upload_guide_title,
          content: sprintf(globalLocalizations.templates_upload_guide_content, [formatCurrency(createTemplateReward)]),
          checked: (ref) {
            TemplatesPageModelState modelState = ref.watch(homeTemplatesProvider);
            return modelState.agreementChecked;
          },
          checkBoxText: globalLocalizations.templates_don_t_prompt_next_time,
          okText: globalLocalizations.common_confirm,
          onCheckBoxChanged: (value) {
            debugPrint("onChanged value=$value");
            model.setAgreementChecked(value!);
          },
          onOkClick: () {
            preferences.putBool(Preferences.KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED, modelState.agreementChecked);
            Navigator.pop(context);
            User? user = ref.read(globalUserInfoProvider);
            if (user == null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
              return;
            }
            showSelectLocalImageActionSheet(
                context: context,
                adjustTemplateImage: true,
                ref: ref,
                onSelected: (file) {
                  if (file == null) {
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TemplateTextSettingScreen(
                                imageFile: file,
                              )));
                });
          });
    });
  }

  void showUseLocalImageNoRewardsDialog() {
    TemplatesPageModelState modelState = ref.watch(homeTemplatesProvider);
    TemplatesPageViewModel model = ref.read(homeTemplatesProvider.notifier);
    _showDialogWithCheckBox(
        title: globalLocalizations.templates_local_image_dialog_title,
        content: globalLocalizations.templates_local_image_dialog_content,
        checked: (ref) {
          TemplatesPageModelState modelState = ref.watch(homeTemplatesProvider);
          return modelState.noRewardsChecked;
        },
        checkBoxText: globalLocalizations.templates_don_t_prompt_next_time,
        okText: globalLocalizations.templates_local_image_dialog_button,
        onCheckBoxChanged: (value) {
          debugPrint("onChanged value=$value");
          model.setNoRewardsChecked(value!);
        },
        onOkClick: () {
          preferences.putBool(Preferences.KEY_USE_LOCAL_IMAGE_NO_REWARDS_CHECKED, modelState.noRewardsChecked);
          Navigator.pop(context);
          pickLocalImageForCreation();
        });
  }

  void _showDialogWithCheckBox({
    required String title,
    required String content,
    required bool Function(WidgetRef ref) checked,
    required String checkBoxText,
    required String okText,
    required Function(bool?) onCheckBoxChanged,
    required Function() onOkClick,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (popContext) {
          double screenHeight = MediaQuery.of(context).size.height;
          double screenWidth = MediaQuery.of(context).size.width;
          return Consumer(builder: (consumerContext, ref, child) {
            return AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              titlePadding: EdgeInsets.only(top: 24, left: 24, right: 24),
              contentPadding: EdgeInsets.all(16),
              content: SizedBox(
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
                                content,
                                style: TextStyle(fontSize: 16, color: designColors.light_06.auto(ref)),
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
                            value: checked(ref),
                            onChanged: onCheckBoxChanged,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          checkBoxText,
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
                          child: MainStyles.outlinedTextButton(ref, globalLocalizations.common_cancel, () {
                            Navigator.pop(context);
                          }),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: MainStyles.gradientButton(ref, okText, onOkClick),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
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
      height: Constants.SECTION_BUTTON_HEIGHT,
      constraints: BoxConstraints(minWidth: Constants.SECTION_BUTTON_WIDTH),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
          child: Text(item.tag,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: item.selected ? Colors.white : designColors.light_06.auto(ref)))),
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
        color: designColors.feiyu_blue.auto(ref),
      )),
      Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
            children: [
          Icon(
            Icons.add,
            color: Colors.white,
            size: 36,
          ),
          Text(
            globalLocalizations.templates_insert_picture,
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
