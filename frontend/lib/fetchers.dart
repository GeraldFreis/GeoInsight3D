/*
 fetchers.dart contains methods for fetching point cloud data from backend
 contains:
    fetchPointCloud
    fetchClasses
*/
import 'package:shared/parsers/point_class.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// getting point cloud data from backend route 8080/points
Future<List<PointXYZ>> fetchPointCloud() async {

    final response = await http.get(Uri.parse('http://localhost:8080/points'));

    if (response.statusCode == 200) {

        // Backend returns an array of points
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => PointXYZ.fromJSON(e)).toList();

    } else {
        throw Exception('Failed to load points from backend');
    }

}

// getting point cloud class analysis from backend route 8080/analysis
Future<List<String>> fetchClasses() async {

    final response = await http.get(Uri.parse('http://localhost:8080/analysis'));

    if (response.statusCode == 200) {

        // Backend returns an array of classes (str)
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => e.toString()).toList();

    } else {
        throw Exception('Failed to load points from backend');
    }

}