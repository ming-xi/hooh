import 'package:app/global.dart';
import 'package:app/ui/pages/home/feeds.dart';
import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/ui/pages/home/input.dart';
import 'package:app/ui/pages/home/me.dart';
import 'package:app/ui/pages/home/templates.dart';
import 'package:app/utils/design_colors.dart';
import 'package:blur/blur.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final StateProvider<bool> bottomBarVisibilityProvider = StateProvider((ref) => true);
final StateNotifierProvider<HomePageViewModel, HomePageModelState> homePageProvider = StateNotifierProvider((ref) {
  return HomePageViewModel(HomePageModelState.init());
});

class HomeScreen extends ConsumerStatefulWidget {
  static const PAGE_INDEX_INPUT = 0;
  static const PAGE_INDEX_TEMPLATES = 1;
  static const PAGE_INDEX_FEEDS = 2;
  static const PAGE_INDEX_ME = 3;

  HomeScreen({
    Key? key,
  }) : super(key: key) {}

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final List<Widget> pageContents;
  late final List<Widget?> floatingButtons;
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    globalHomeScreenIsInStack = true;
    pageContents = [
      InputPage(),
      GalleryPage(),
      FeedsPage(),
      MePage(),
    ];
    floatingButtons = [
      null,
      null,
      null,
      null,
    ];
    // User? user = ref.read(globalUserInfoProvider);
    // if (user != null) {
    //   network.requestAsync<User>(network.getUserInfo(user.id), (data) {
    //     ref.read(globalUserInfoProvider.state).state = data;
    //   }, (error) {});
    // }
  }

  @override
  void dispose() {
    controller.dispose();
    globalHomeScreenIsInStack = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HomePageModelState modelState = ref.watch(homePageProvider);
    debugPrint("home tab_index=${modelState.tabIndex}");
    return Scaffold(
      floatingActionButton: floatingButtons[modelState.tabIndex],
      extendBody: true,
      body: pageContents[modelState.tabIndex],
      bottomNavigationBar: AnimatedSlide(
        duration: Duration(milliseconds: 250),
        offset: Offset(0, ref.watch(bottomBarVisibilityProvider.state).state ? 0 : 1),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.input), label: "input"),
              BottomNavigationBarItem(icon: Icon(Icons.image), label: "album"),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: "explore"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "person"),
            ],
            selectedItemColor: designColors.feiyu_blue.auto(ref),
            unselectedItemColor: designColors.dark_03.auto(ref),
            onTap: (index) {
              FocusManager.instance.primaryFocus?.unfocus();
              ref.read(homePageProvider.notifier).updateTabIndex(index);
              // if (index == HomeScreen.PAGE_INDEX_ME) {
              //   User? user = ref.read(globalUserInfoProvider);
              //   if (user != null) {
              //     network.requestAsync<User>(network.getUserInfo(user.id), (data) {
              //       ref.read(globalUserInfoProvider.state).state = data;
              //     }, (error) {});
              //   }
              // }
            },
            currentIndex: modelState.tabIndex,
          ),
        ).frosted(
          blur: 10,
          frostColor: designColors.light_01.auto(ref),
          frostOpacity: 0.9,
        ),
      ),
    );
  }

  String getTitle(int index) {
    switch (index) {
      case 0:
        return "input";
      case 1:
        return "gallery";
      case 2:
        return "social";
      case 3:
        return "me";
      default:
        return "";
    }
  }
}
