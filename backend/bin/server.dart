/*
    server.dart handles server functions including:
        parsing csv files
        calculating analysis on points
*/

import 'dart:convert';
import 'dart:io';
import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';
 // For CSV parsing
import 'package:shared/parsers/point_class.dart';
import 'package:shared/parsers/xyz_parser.dart';
import '../lib/analysers/classification.dart';

List<PointXYZ> _cached_points = <PointXYZ>[]; // Global variable for caching
bool _changed_points = false; // global variable for retrieving new points
// main to catch api requests and read the csv file

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
            final List<PointXYZ> point_cloud;
            if(_changed_points == false) {
                point_cloud = await parseCustomPointCloud('../assets/test3.csv'); // I want to read the big one as base
                _cached_points = point_cloud;
            } else { 
                point_cloud = _cached_points;
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

        } else  if (request.uri.path == '/analysis') {

            if(!_cached_points.isEmpty){

                final classes = await calculateLowAndHigh(_cached_points); // returns json object of class for each point
                
                request.response
                    ..headers.contentType = ContentType.json
                    ..write(jsonEncode(classes))
                    ..close();
                
            }
        } else if(request.uri.path == '/upload' && request.method == 'POST') {
            // saving the sent file, and returning the points
            try {
                // Ensure upload directory exists
                final uploadDir = Directory('../assets/uploads');
                if (!uploadDir.existsSync()) {
                uploadDir.createSync(recursive: true);
                }

                // Validate multipart/form-data
                final contentType = request.headers.contentType;
                if (contentType == null || !contentType.mimeType.contains("multipart/form-data")) {
                request.response.statusCode = 400;
                request.response.write("Expected multipart/form-data");
                await request.response.close();
                return;
                }

                final boundary = contentType.parameters['boundary'];
                if (boundary == null) {
                request.response.statusCode = 400;
                request.response.write("Missing multipart boundary");
                await request.response.close();
                return;
                }

                // Create transformer
                final transformer = MimeMultipartTransformer(boundary);

                String? filename;
                List<int> fileBytes = [];

                // Break request into MIME parts
                await for (final MimeMultipart part in request.cast<List<int>>().transform(transformer)) {

                final formData = HttpMultipartFormData.parse(part);

                final name = formData.contentDisposition.parameters['name'];

                if (name == 'file') {
                    filename = formData.contentDisposition.parameters['filename'] ?? "upload.csv";

                    // If file bytes come as binary
                    if (formData.isBinary) {
                    await for (final chunk in formData.cast<List<int>>()) {
                        fileBytes.addAll(chunk);
                    }
                    } else {
                    // If file comes as text (string chunks)
                    await for (final chunk in formData) {
                        final str = chunk as String;
                        fileBytes.addAll(utf8.encode(str));
                    }
                    }
                }
                }

                if (filename == null) {
                request.response.statusCode = 400;
                request.response.write("File missing in form-data");
                await request.response.close();
                return;
                }

                // Save file
                final savePath = "../assets/uploads/$filename";
                await File(savePath).writeAsBytes(fileBytes);
                print("File saved -> $savePath");

                // Parse CSV
                final points = await parseCustomPointCloud(savePath);
                _cached_points = points;
                _changed_points = true;
                final jsonPoints = points
                    .map((p) => {
                        "x": p.x,
                        "y": p.y,
                        "z": p.z,
                        "intensity": p.intensity,
                        })
                    .toList();

                request.response
                ..headers.contentType = ContentType.json
                ..write(jsonEncode(jsonPoints))
                ..close();

            } catch (e) {
                print("UPLOAD FAILED: $e");
                request.response.statusCode = 500;
                request.response.write("Upload failed: $e");
                await request.response.close();
            }
            
        } else {

        request.response
            ..statusCode = HttpStatus.notFound
            ..write('Not found')
            ..close();

        }
    }

}

