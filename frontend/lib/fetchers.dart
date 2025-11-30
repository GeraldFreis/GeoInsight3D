/*
 fetchers.dart contains methods for fetching point cloud data from backend
 contains:
    fetchPointCloud
    fetchClasses
    sendCSV
*/
import 'package:shared/parsers/point_class.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
// uploading a csv to 8080/upload
Future<bool> sendCSV() async {
    final input = html.FileUploadInputElement()..accept = ".csv";
    input.click();

    // wait for file selection
    await input.onChange.first;

    // if no file selected
    final file = input.files?.first;
    if (file == null) return false;

    final reader = html.FileReader()..readAsArrayBuffer(file);

    // wait for file loading then send
    await reader.onLoad.first;

    final bytes = reader.result as Uint8List;

    final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://localhost:8080/upload"),
    );

    // adding file to request
    request.files.add(
        http.MultipartFile.fromBytes(
        "file",
        bytes,
        filename: file.name,
        contentType: MediaType("text", "csv"),
        ),
    );

    // send off to backend
    final response = await request.send();
    
    return response.statusCode == 200;
}