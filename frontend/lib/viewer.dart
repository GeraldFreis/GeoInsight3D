/*
    viewer.dart contains the viewing model responsible for plotting the points and manipulating these plots
    contains:
        class PointCloudViewer
        class PointCloudPainter
*/
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared/parsers/point_class.dart';

// helper to convert intensity from lidar to colour
/*
    in: double intensity
    out: Color intensity (Color = HSVColor (material.dart))
*/
Color intensityToColor(double intensity) {
  // Clamp intensity to [0, 1] range if needed
  double t = (intensity / 600).clamp(0, 1);

  return HSVColor.lerp(
    HSVColor.fromAHSV(1, 240, 1, 1), // Blue
    HSVColor.fromAHSV(1, 0, 1, 1),   // Red
    t,
  )!.toColor();
}

/*
    PointCloudViewer
    variables:
         final List<PointXYZ> points;
        // getting class we need to highlight
        final List<String>? point_classes;
        final String? highlight_class;
    methods:
        create_state: returns pointCloudViewerState object
*/
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

/*
    Private class used for rotating pov & exacting co-ordinates of points on screen
*/
class _PointCloudViewerState extends State<PointCloudViewer> {
    double yaw = 0;     // left-right rotation
    double pitch = 0;   // up-down rotation
    double zoom = 300;  // camera distance

    Offset? last_pos;

    // building the gesture listeners for scroll events or mouse movements
    @override
    Widget build(BuildContext context) {

        return GestureDetector(

            onPanStart: (d) => last_pos = d.localPosition,
            onPanUpdate: (d) { // when user drags (gesture)

                final dx = d.localPosition.dx - last_pos!.dx;
                final dy = d.localPosition.dy - last_pos!.dy;
                
                if (dx.abs() < 0.5 && dy.abs() < 0.5) return; // 👈 ignore tiny jitter

                last_pos = d.localPosition;
                setState(() {
                yaw += dx * 0.01;
                pitch += dy * 0.01;
            });
        },
        child: Listener(

            onPointerSignal: (signal) { // when scrolling with mouse

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

/*
    PointCloudPainter is used to paint the points on the screen according to offsets and gestures
    variables:
        final List<PointXYZ> points;
        final List<String>? point_classes;
        final String? highlight_class;

        final double yaw, pitch, zoom;
    methods:
        void paint(Canvas c, Size s);
*/
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
        }
    );

    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint();

        final cx = size.width / 2;
        final cy = size.height / 2;

        // Precompute rotation
        final cos_y = cos(yaw), sin_y = sin(yaw);
        final cos_p = cos(pitch), sin_p = sin(pitch);

        for (int i = 0; i < points.length; i++) {

            final p = points[i];

            // if the current point is part of a class that we want to highlight
            if(highlight_class != null && point_classes != null && point_classes!.length > i && point_classes![i] == highlight_class) { // if the current point is one of the highlighted class
                paint.color = Colors.red;
            } else {
                paint.color = intensityToColor(p.intensity);
            }
            
            // because z needs to be elevation I want a side view mapping:
            // i.e. viewing from y as horizontal axis, x is depth, z is elevation / vertical
            double sx = p.y;       
            double sy = p.z;       
            double sz = p.x;       

            // calculating rotation (horizontal)
            double x = sx * cos_y - sz * sin_y;
            double z = sx * sin_y + sz * cos_y;

            // calculating vertical movement 
            double y = sy * cos_p - z * sin_p;
            z = sy * sin_p + z * cos_p;

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