/*
    get_points.dart handles /points endpoint
    contains:
        void getPoints(HttpRequest req) {async}
*/
import 'dart:convert'; // for casting
import 'dart:io'; 
import '../cache.dart'; // for global variables

import 'package:shared/parsers/xyz_parser.dart'; // parseCustomPointCloud
import 'package:shared/parsers/point_class.dart'; // PointXYZ

import 'package:http_server/http_server.dart';

/*
    getPoints
    in: HttpRequest request
    out: response containing json points of parsed Point Cloud
*/
Future<void> getPoints(HttpRequest request) async {
    final List<PointXYZ> point_cloud;

    if(changed_points == false) { // if this is the first read 
        point_cloud = await parseCustomPointCloud('../assets/test_well.csv'); // I want to read the big one as base
        cached_points = point_cloud;
    } else { 
        point_cloud = cached_points;
    }

    final json_points = point_cloud.map((p) => { // ensuring we in json
        'x': p.x,
        'y': p.y,
        'z': p.z,
        'intensity': p.intensity,
    }).toList();

    request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(json_points))
        ..close();
    
    return;
}