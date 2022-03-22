import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GallerySearchScreen extends ConsumerStatefulWidget {
  const GallerySearchScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _GallerySearchScreenState();
}

class _GallerySearchScreenState extends ConsumerState<GallerySearchScreen> {
  @override
  Widget build(BuildContext context) {
    double safePadding = MediaQuery.of(context).padding.top;
    double padding = 16.0;
    double iconSize = 24.0;
    double totalHeight = padding * 3 + iconSize;
    totalHeight += padding;
    var searchBar = buildSearchBar(context, iconSize, padding);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(totalHeight),
        child: Builder(builder: (context) {
          return AppBar(
            toolbarHeight: totalHeight,
            elevation: 0,
            title: searchBar,
            titleSpacing: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ).frosted(
            blur: 10,
            frostColor: Colors.white,
            frostOpacity: 0.9,
          );
        }),
      ),
      body: Container(),
    );
  }

  Widget buildSearchBar(BuildContext context, double iconSize, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, padding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: const Color(0xFFEAEAEA),
        ),
        child: GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Container(
                  child: SvgPicture.asset('assets/images/icon_search.svg', height: iconSize, width: iconSize),
                  padding: EdgeInsets.fromLTRB(0, padding, padding, padding)),
              const Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      hintText: 'search',
                      border: InputBorder.none,
                    ),
                  ),
              ),
              SizedBox(width: padding),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                style: const ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                ),
              )
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
      ),
    );
  }
}
