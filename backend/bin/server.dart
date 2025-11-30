/*
    server.dart handles server functions including:
        parsing csv files
        calculating analysis on points
*/

import 'dart:convert';
import 'dart:io';
import 'package:http_server/http_server.dart';

 // For CSV parsing
import './cache.dart'; // for global variables

// handling endpoints
import './endpoint_controllers/get_points.dart'; // handling /points endpoint
import './endpoint_controllers/get_analysis.dart'; // handling /points endpoint
import './endpoint_controllers/get_upload.dart'; // handling /points endpoint

// main to catch api requests and send them out to required functions
Future<void> main() async {
    // linking the jawn to 8080
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    print('Server running on http://localhost:8080');

    await for (HttpRequest request in server) {

        // Allow requests from any origin
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        request.response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type');

        // Handle preflight requests (OPTIONS)
        if (request.method == 'OPTIONS') {
            request.response.statusCode = HttpStatus.ok;
            await request.response.close();
            continue;
        }

        if(request.uri.path == '/points') { // user wants us to pass the points back; like cmon man lets dig into it
            // lets parse the jawn
            await getPoints(request);
            
        } else  if (request.uri.path == '/analysis') {
            await getAnalysis(request);
            
        } else if(request.uri.path == '/upload' && request.method == 'POST') {
            // saving the sent file, and returning the points
            await getUpload(request);
            
        } else {

        request.response
            ..statusCode = HttpStatus.notFound
            ..write('Not found')
            ..close();

        }
    }

}

