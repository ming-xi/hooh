import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _InputPageState();
}

class _InputPageState extends ConsumerState<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Container(
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: const Color(0xFFEAEAEA),
                        ),
                        child: (Row(
                          children: [
                            SvgPicture.asset('assets/images/icon_search.svg', height: 24, width: 24),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('search'))
                          ],
                        )),
                        padding: EdgeInsets.all(10),
                      ),
                    ),
                    Container(
                      width: 20,
                    ),
                  ],
                ),
                height: 44,
              ),
              const SizedBox(
                height: 80,
              )
            ],
          ),
        ),
      ),
    );
  }
}
