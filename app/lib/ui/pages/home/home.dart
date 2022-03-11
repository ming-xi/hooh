import 'package:app/ui/pages/home/gallery.dart';
import 'package:app/ui/pages/home/input.dart';
import 'package:app/ui/pages/home/me.dart';
import 'package:app/ui/pages/home/social.dart';
import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final bottomBarVisibilityProvider = StateProvider((ref) => true);

class HomeScreen extends ConsumerStatefulWidget {
  final pageIndexProvider = StateProvider((ref) => 0);

  HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Widget> pages = const [
    InputPage(),
    GalleryPage(),
    SocialPage(),
    MePage(),
  ];
  ScrollController controller = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int index = ref.watch(widget.pageIndexProvider);
    return Scaffold(
      extendBody: true,
      body: pages[index],
      bottomNavigationBar: AnimatedSlide(
        duration: Duration(milliseconds: 250),
        offset: Offset(0, ref.watch(bottomBarVisibilityProvider.state).state ? 0 : 1),
        child: SafeArea(
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
                BottomNavigationBarItem(icon: Icon(Icons.album), label: "album"),
                BottomNavigationBarItem(icon: Icon(Icons.explore), label: "explore"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "person"),
              ],
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                // HomeScreenState state = ref.read(widget.provider);
                ref.read(widget.pageIndexProvider.state).state = index;
              },
              currentIndex: index,
            ),
          ).frosted(
            blur: 2.5,
            frostColor: Colors.white,
          ),
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
// 是希希帮了大忙找到的代码~有很大的启发~
// class ScrollToHideWidget extends StatefulWidget {
//   final Widget child;
//   final ScrollController controller;
//   final Duration duration;
//
//   const ScrollToHideWidget({
//     Key? key,
//     required this.child,
//     required this.controller,
//     this.duration = const Duration(milliseconds: 250),
//   }) : super(key: key);
//
//   @override
//   State<ScrollToHideWidget> createState() => _ScrollToHideWidgetState();
// }
//
// class _ScrollToHideWidgetState extends State<ScrollToHideWidget> {
//   bool isVisible = true;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     widget.controller.addListener(listen);
//   }
//
//   void listen() {
//     final direction = widget.controller.position.userScrollDirection;
//     if (direction == ScrollDirection.forward) {
//       show();
//     } else if (direction == ScrollDirection.reverse) {
//       hide();
//     }
//   }
//
//   void show() {
//     if (!isVisible) setState(() => isVisible = true);
//   }
//
//   void hide() {
//     if (isVisible) setState(() => isVisible = false);
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     widget.controller.removeListener(listen);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) => AnimatedContainer(
//         duration: widget.duration,
//         height: isVisible ? 140 : 0,
//         child: Wrap(children: [widget.child]),
//       );
// }
