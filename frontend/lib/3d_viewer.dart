import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:shared/parsers/point_class.dart';

// conversion function for pointCloud list to a float32 list for gpu
Float32List makeVertexBuffer(List<PointXYZ> pointCloud) {
  double minIntensity = pointCloud.map((p) => p.intensity).reduce((a, b) => a < b ? a : b);
  double maxIntensity = pointCloud.map((p) => p.intensity).reduce((a, b) => a > b ? a : b);

  final list = Float32List(pointCloud.length * 6); // 3 for pos, 3 for color

  for (int i = 0; i < pointCloud.length; i++) {
    final point = pointCloud[i];
    int index = i * 6;
    list[index] = point.x.toDouble();
    list[index + 1] = point.y.toDouble();
    list[index + 2] = point.z.toDouble();

    double normIntensity = ((point.intensity - minIntensity) / (maxIntensity - minIntensity)).clamp(0.0, 1.0);
    list[index + 3] = normIntensity;
    list[index + 4] = normIntensity;
    list[index + 5] = normIntensity;
  }

  return list;
}

// shader source
const String vertexShaderSource = """
attribute vec3 position;
attribute vec3 color;
varying vec3 vColor;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
void main() {
  vColor = color;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  gl_PointSize = 2.0;
}
""";

const String fragmentShaderSource = """
precision mediump float;
varying vec3 vColor;
void main() {
  gl_FragColor = vec4(vColor, 1.0);
}
""";
