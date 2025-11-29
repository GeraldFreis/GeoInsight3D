import 'package:shared/parsers/xyz_parser.dart';
import 'package:flutter/material.dart';
import './3d_viewer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final points = await parseBasePointCloud();
  
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(title: Text("LiDAR Point Cloud Viewer")),
//       body: Center(
//         child: PointCloudViewer(points: points),
//       ),
//     ),
//   ));
}
