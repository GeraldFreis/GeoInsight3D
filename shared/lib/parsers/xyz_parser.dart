/*
xyz_parser.dart handles the parsing of csv files in lidar format, returning a usable object for the rendering and analysis that occurs afterwards
*/
import 'package:flutter/services.dart' show rootBundle;
import './point_class.dart'; // base class PointXYZ

// base method for parsing test2.csv 
Future<List<PointXYZ>> parseBasePointCloud() async {
    final file = await rootBundle.loadString('assets/test2.csv');
    final lines = file.split('\n');

    // not handling exceptions because it will always exist unless someone decides to delete it

    final pointCloud = <PointXYZ>[];

    for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final components = line.split(','); // assuming here that it is a csv

        pointCloud.add(
            PointXYZ(
                double.parse(components[0]),
                double.parse(components[1]),
                double.parse(components[2]),
                double.parse(components[3])
            )
        );
    }

    return pointCloud;
}



