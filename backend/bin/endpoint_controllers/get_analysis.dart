/*
    get_analysis.dart handles /analysis endpoint
    contains:
        void getAnalysis(HttpRequest req) {async}
*/

import 'dart:convert'; // for casting
import 'dart:io'; 
import '../cache.dart'; // for global variables

import '../../lib/analysers/classification.dart'; // for classifying points

/*
    getPoints
    in: HttpRequest request
    out: response containing List<String> {"Low", "High", "Inconsequential", "Building"}
*/
Future<void> getAnalysis(HttpRequest request) async {

    if(!cached_points.isEmpty){ // if we have actually read the points yet

    final classes = await calculateClasses(cached_points); // returns json object of class for each point
    
    request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(classes))
        ..close();
    
    }

    return;
}
