import 'dart:ui';
import 'dart:ui' as ui;

import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

///断面绘制控件
class DrawBadgeView extends ConsumerStatefulWidget {
  final ui.Image? image;
  Color paintColor;

  DrawBadgeView({required this.image, required this.paintColor});

  @override
  _DrawBadgeViewState createState() => _DrawBadgeViewState();
}

class _DrawBadgeViewState extends ConsumerState<DrawBadgeView> {
  bool willChange = false;
  Offset? pointer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: designColors.dark_03.auto(ref))),
      child: InteractiveViewer(
        maxScale: 5,
        child: GestureDetector(
          onTapDown: (detail) {
            debugPrint("onTapDown detail=${detail.localPosition}");
            setState(() {
              pointer = detail.localPosition;
            });
          },
          onTapUp: (detail) {
            debugPrint("onTapUp detail=${detail.localPosition}");
            // setState(() {
            //   pointer = null;
            // });
          },
          child: CustomPaint(
            willChange: willChange,
            painter: CanvasPainter(ref, widget.image, pointer),
          ),
        ),
      ),
    );
  }
}

class CanvasPainter extends CustomPainter {
  static const CANVAS_PIXEL_WIDTH = 20;
  static const CANVAS_PIXEL_HEIGHT = 20;
  late final Color darkerGridColor;
  late final Color gridColor;
  late final Color backgroundColor;
  final ui.Image? image;
  final Paint p = Paint();
  Offset? pointer;

  CanvasPainter(WidgetRef ref, this.image, this.pointer) {
    darkerGridColor = designColors.light_02.auto(ref);
    gridColor = designColors.light_01.auto(ref);
    backgroundColor = designColors.light_03.auto(ref);
    debugPrint("darkerGridColor=$darkerGridColor");
    debugPrint("gridColor=$gridColor");
    p.strokeCap = StrokeCap.square;
    p.strokeWidth = 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("size=$size");
    canvas.save();
    double scale = (size.width / CANVAS_PIXEL_WIDTH);
    canvas.scale(scale, (size.height / CANVAS_PIXEL_HEIGHT));
    drawNonEditableBackground(canvas);
    // if (image != null) {
    //   debugPrint("draw image");
    //   canvas.drawImage(image!, Offset(((CANVAS_PIXEL_WIDTH - image!.width) ~/ 2).toDouble(), ((CANVAS_PIXEL_HEIGHT - image!.height) ~/ 2).toDouble()), p);
    // }
    drawPointer(canvas, scale);
    canvas.restore();
  }

  void drawPointer(Canvas canvas, double scale) {
    if (pointer != null) {
      canvas.translate(0.5, 0.5);
      p.color = Colors.red;
      var scale2 = pointer!.scale(1 / scale, 1 / scale);
      double x = (scale2.dx).floorToDouble();
      double y = (scale2.dy).floorToDouble();
      scale2 = Offset(x, y);
      debugPrint("pointer=$scale2");
      canvas.drawPoints(PointMode.points, [scale2], p);
      canvas.translate(-0.5, -0.5);
    }
  }

  void drawEditableBackground(Canvas canvas) {}

  void drawNonEditableBackground(Canvas canvas) {
    canvas.drawColor(Colors.transparent, BlendMode.src);

    List<Offset> grid = [];
    List<Offset> darkGrid = [];
    for (int i = 0; i < CANVAS_PIXEL_WIDTH; i++) {
      for (int j = 0; j < CANVAS_PIXEL_HEIGHT; j++) {
        if ((i + j) % 2 == 0) {
          darkGrid.add(Offset(i.toDouble(), j.toDouble()));
        } else {
          grid.add(Offset(i.toDouble(), j.toDouble()));
        }
      }
    }
    if (image != null) {
      debugPrint("draw mask");
      canvas.drawImage(image!, Offset(((CANVAS_PIXEL_WIDTH - image!.width) ~/ 2).toDouble(), ((CANVAS_PIXEL_HEIGHT - image!.height) ~/ 2).toDouble()), p);
    }
    p.blendMode = BlendMode.srcIn;
    canvas.translate(0.5, 0.5);
    p.color = gridColor;
    canvas.drawPoints(PointMode.points, grid, p);
    p.color = darkerGridColor;
    canvas.drawPoints(PointMode.points, darkGrid, p);
    canvas.translate(-0.5, -0.5);
    canvas.drawColor(backgroundColor, BlendMode.dstOver);
    p.blendMode = BlendMode.srcOver;
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return this != oldDelegate;
  }
}
