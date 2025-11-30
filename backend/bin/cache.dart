/*
 cache.dart contains two global variables for the backend:
    List<PointXYZ> cached_points
    bool changed_points 
*/
import 'package:shared/parsers/point_class.dart'; // for PointXYZ

List<PointXYZ> cached_points = <PointXYZ>[]; // Global variable for caching
bool changed_points = false; // global variable for retrieving new points