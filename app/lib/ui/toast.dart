//通过 Overlay 实现 Toast
import 'package:flutter/material.dart';

class Toast {
  static void show({required BuildContext context, required String message}) {
    //1、创建 overlayEntry
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          top: MediaQuery.of(context).size.height * 0.8,
          child: Material(
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(message),
                  ),
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
            ),
          ));
    });

    //插入到 Overlay中显示 OverlayEntry
    Overlay.of(context)?.insert(overlayEntry);

    //延时两秒，移除 OverlayEntry
    Future.delayed(Duration(seconds: 2)).then((value) {
      overlayEntry.remove();
    });
  }
}
