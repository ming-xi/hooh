import 'package:app/ui/pages/home/home_view_model.dart';
import 'package:app/ui/pages/home/input.dart';
import 'package:app/ui/pages/home/input_view_model.dart';
import 'package:app/ui/pages/home/me.dart';
import 'package:app/ui/pages/home/social.dart';
import 'package:app/ui/pages/home/templates.dart';
import 'package:app/utils/design_colors.dart';
import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final bottomBarVisibilityProvider = StateProvider((ref) => true);

class HomeScreen extends ConsumerStatefulWidget {
  final StateNotifierProvider<HomePageViewModel, HomePageModelState> homePageProvider = StateNotifierProvider((ref) {
    return HomePageViewModel(HomePageModelState.init());
  });

  HomeScreen({
    Key? key,
  }) : super(key: key);

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
    pageContents = [
      InputPage(),
      GalleryPage(widget.homePageProvider),
      SocialPage(),
      MePage(),
    ];
    floatingButtons = [
      null,
      null,
      null,
      null,
    ];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HomePageModelState modelState = ref.watch(widget.homePageProvider);
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
              ref.read(widget.homePageProvider.notifier).updateTabIndex(index);
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
// import 'package:app/ui/pages/home/home_view_model.dart';
// import 'package:app/ui/pages/home/input.dart';
// import 'package:app/ui/pages/home/me.dart';
// import 'package:app/ui/pages/home/social.dart';
// import 'package:app/ui/pages/home/templates.dart';
// import 'package:app/utils/design_colors.dart';
// import 'package:blur/blur.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
//
// final bottomBarVisibilityProvider = StateProvider((ref) => true);
//
// class HomeScreen extends ConsumerStatefulWidget {
//   final StateNotifierProvider<HomePageViewModel, HomePageModelState> homePageProvider = StateNotifierProvider((ref) {
//     return HomePageViewModel(HomePageModelState.init());
//   });
//
//   HomeScreen({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   ConsumerState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   late final List<Widget> pageContents;
//   late final List<Widget?> floatingButtons;
//   final ScrollController controller = ScrollController();
//   late final PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     pageContents = [
//       InputPage(),
//       GalleryPage(widget.homePageProvider),
//       SocialPage(),
//       MePage(),
//     ];
//     floatingButtons = [
//       null,
//       null,
//       null,
//       null,
//     ];
//
//     _pageController = PageController(initialPage: ref.read(widget.homePageProvider).tabIndex);
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     HomePageModelState modelState = ref.watch(widget.homePageProvider);
//     debugPrint("home tab_index=${modelState.tabIndex}");
//     return Scaffold(
//       floatingActionButton: floatingButtons[modelState.tabIndex],
//       extendBody: true,
//       // body: pageContents[modelState.tabIndex],
//       body: PageView(
//         children: pageContents,
//         controller: _pageController,
//         physics: NeverScrollableScrollPhysics(),
//       ),
//       bottomNavigationBar: AnimatedSlide(
//         duration: Duration(milliseconds: 250),
//         offset: Offset(0, ref.watch(bottomBarVisibilityProvider.state).state ? 0 : 1),
//         child: Theme(
//           data: Theme.of(context).copyWith(
//             canvasColor: Colors.transparent,
//           ),
//           child: BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             showSelectedLabels: false,
//             showUnselectedLabels: false,
//             elevation: 0,
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.input), label: "input"),
//               BottomNavigationBarItem(icon: Icon(Icons.image), label: "album"),
//               BottomNavigationBarItem(icon: Icon(Icons.explore), label: "explore"),
//               BottomNavigationBarItem(icon: Icon(Icons.person), label: "person"),
//             ],
//             selectedItemColor: designColors.feiyu_blue.auto(ref),
//             unselectedItemColor: designColors.dark_03.auto(ref),
//             onTap: (index) {
//               FocusManager.instance.primaryFocus?.unfocus();
//               ref.read(widget.homePageProvider.notifier).updateTabIndex(index);
//               _pageController.jumpToPage(index);
//             },
//             currentIndex: modelState.tabIndex,
//           ),
//         ).frosted(
//           blur: 10,
//           frostColor: designColors.light_01.auto(ref),
//           frostOpacity: 0.9,
//         ),
//       ),
//     );
//   }
//
//   String getTitle(int index) {
//     switch (index) {
//       case 0:
//         return "input";
//       case 1:
//         return "gallery";
//       case 2:
//         return "social";
//       case 3:
//         return "me";
//       default:
//         return "";
//     }
//   }
// }
