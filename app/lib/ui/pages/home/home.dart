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
  final pageIndexProvider = StateProvider((ref) => 1);

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
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              // HomeScreenState state = ref.read(widget.provider);
              ref.read(widget.pageIndexProvider.state).state = index;
            },
            currentIndex: index,
          ),
        ).frosted(
          blur: 10,
          frostColor: Colors.white,
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
