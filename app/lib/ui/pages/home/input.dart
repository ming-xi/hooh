import 'package:app/global.dart';
import 'package:app/launcher.dart';
import 'package:app/test.dart';
import 'package:app/ui/pages/creation/recommended_templates.dart';
import 'package:app/ui/pages/home/input_view_model.dart';
import 'package:app/ui/pages/user/register/start.dart';
import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/design_colors.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InputPage extends ConsumerStatefulWidget {
  final StateNotifierProvider<InputPageViewModel, InputPageModelState> provider = StateNotifierProvider((ref) {
    return InputPageViewModel(InputPageModelState.init());
  });

  InputPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<InputPage> with WidgetsBindingObserver {
  TextEditingController controller = TextEditingController();
  late InputPageViewModel modelRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    modelRef = ref.read(widget.provider.notifier);
    List<String> strings = modelRef.readFromDraft(needsUpdate: false);
    controller.text = strings.isEmpty ? "" : strings[0];
  }

  @override
  void dispose() {
    modelRef.saveDraft(controller.text);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputPageModelState modelState = ref.watch(widget.provider);
    InputPageViewModel model = ref.read(widget.provider.notifier);
    return Stack(children: [
      buildBackground(modelState),
      CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                Spacer(),
                AspectRatio(
                  aspectRatio: 1.465,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(left: 30, right: 30, bottom: 32),
                          child: Container(
                            decoration: BoxDecoration(color: designColors.light_01.auto(ref), borderRadius: BorderRadius.circular(24)),
                            padding: EdgeInsets.only(bottom: 8),
                            child: TextField(
                              controller: controller,
                              onChanged: (text) {
                                model.updateButtonState(text.isNotEmpty);
                              },
                              maxLength: InputPageModelState.MAX_CONTENT_LENGTH,
                              maxLines: null,
                              expands: true,
                              style: TextStyle(color: designColors.dark_01.auto(ref), fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                  hintText: globalLocalizations.input_hint,
                                  hintStyle: TextStyle(color: designColors.light_06.auto(ref), fontWeight: FontWeight.bold),
                                  helperStyle: TextStyle(fontWeight: FontWeight.bold, color: designColors.dark_03.auto(ref), fontSize: 11),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 12, right: 12, top: 24, bottom: 24)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Center(
                            child: SizedBox(
                                width: 180,
                                child: MainStyles.gradientButton(
                                    ref,
                                    globalLocalizations.input_go,
                                    !modelState.isStartButtonEnabled
                                        ? null
                                        : () {
                                            User? user = ref.read(globalUserInfoProvider);
                                            if (user == null) {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => StartScreen()));
                                              return;
                                            }
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            List<String> texts = updateModelText();
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => RecommendedTemplatesScreen(contents: texts)));
                                          },
                                    cornerRadius: 22))),
                        left: 0,
                        right: 0,
                        bottom: 0,
                      ),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
          )
        ],
      ),
      Visibility(
        visible: FlavorConfig.instance.variables[Launcher.KEY_ADMIN_MODE],
        child: Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: FloatingActionButton(
              child: Icon(Icons.code),
              onPressed: () {
                updateModelText();
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.push(context, MaterialPageRoute(builder: (context) => TestMenuScreen()));
              },
            ),
          ),
        ),
      )
    ]);
  }

  List<String> updateModelText() {
    InputPageViewModel model = ref.read(widget.provider.notifier);
    return model.updateInputText(controller.text);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        InputPageModelState modelState = ref.read(widget.provider);
        controller.text = modelState.inputStrings.isNotEmpty ? modelState.inputStrings[0] : "";
        break;
      case AppLifecycleState.inactive:
        updateModelText();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Widget buildBackground(InputPageModelState modelState) {
    Container placeholder = Container(
      color: designColors.light_02.auto(ref),
    );
    Size size = MediaQuery.of(context).size;
    String? url = modelState.backgroundImageUrl;
    if (url == null) {
      return placeholder;
    } else {
      return CachedNetworkImage(
        width: size.width,
        height: size.height,
        fit: BoxFit.cover,
        cacheKey: network.getS3ImageKey(url),
        imageUrl: url,
        errorWidget: (context, url, error) => placeholder,
        placeholder: (context, url) => placeholder,
      ).blurred(blur: 10, colorOpacity: 0.2, blurColor: Colors.white);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
