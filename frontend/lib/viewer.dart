import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared/parsers/point_class.dart';

Color intensityToColor(double intensity) {
  // Clamp intensity to [0, 1] range if needed
  double t = (intensity / 600).clamp(0, 1);

  return HSVColor.lerp(
    HSVColor.fromAHSV(1, 240, 1, 1), // Blue
    HSVColor.fromAHSV(1, 0, 1, 1),   // Red
    t,
  )!.toColor();
}

class PointCloudViewer extends StatefulWidget {
    final List<PointXYZ> points;
    // getting class we need to highlight
    final List<String>? point_classes;
    final String? highlight_class;

  const PointCloudViewer({
        super.key,
        required this.points,
        required this.point_classes,
        required this.highlight_class,
    });

  @override
  State<PointCloudViewer> createState() => _PointCloudViewerState();

}

class _PointCloudViewerState extends State<PointCloudViewer> {
  double yaw = 0;     // left-right rotation
  double pitch = 0;   // up-down rotation
  double zoom = 300;  // camera distance

  Offset? lastPos;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) => lastPos = d.localPosition,
      onPanUpdate: (d) {
        final dx = d.localPosition.dx - lastPos!.dx;
        final dy = d.localPosition.dy - lastPos!.dy;
        lastPos = d.localPosition;
        setState(() {
          yaw += dx * 0.01;
          pitch += dy * 0.01;
        });
      },
      child: Listener(
        onPointerSignal: (signal) {
          if (signal is PointerScrollEvent) {
            setState(() => zoom -= signal.scrollDelta.dy);
          }
        },
        child: CustomPaint(
          painter: PointCloudPainter(
            widget.points,
            yaw,
            pitch,
            zoom,
            point_classes: widget.point_classes,
            highlight_class: widget.highlight_class,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class PointCloudPainter extends CustomPainter {
  final List<PointXYZ> points;
  final List<String>? point_classes;
  final String? highlight_class;

  final double yaw, pitch, zoom;

  PointCloudPainter(
    this.points,
    this.yaw,
    this.pitch, 
    this.zoom,
    {
        required this.point_classes,
        required this.highlight_class,
    });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Precompute rotation
    final cosY = cos(yaw), sinY = sin(yaw);
    final cosP = cos(pitch), sinP = sin(pitch);

    for (int i = 0; i < points.length; i++) {

        final p = points[i];

        if(highlight_class != null && point_classes != null && point_classes!.length > i && point_classes![i] == highlight_class) { // if the current point is one of the highlighted class
            paint.color = Colors.red;
        } else {
            paint.color = intensityToColor(p.intensity);
        }
        // SIDE VIEW MAPPING
        double sx = p.y;       // horizontal axis = y
        double sy = p.z;       // vertical axis   = elevation
        double sz = p.x;       // depth axis      = x (camera looks along x)

        // ROTATION (yaw = turning head left/right)
        double x = sx * cosY - sz * sinY;
        double z = sx * sinY + sz * cosY;

        // PITCH (tilting head up/down)
        double y = sy * cosP - z * sinP;
        z = sy * sinP + z * cosP;

        // Perspective projection
        double scale = zoom / (zoom + z);
        double px = x * scale + cx;
        double py = -y * scale + cy;

        canvas.drawCircle(Offset(px, py), 2, paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}