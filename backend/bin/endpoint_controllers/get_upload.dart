/*
    get_upload.dart handles /upload endpoint
    contains:
        void getUpload(HttpRequest req) {async}
*/

import 'dart:convert';
import 'dart:io';
import 'package:http_server/http_server.dart';
import 'package:mime/mime.dart';

 // For CSV parsing
import 'package:shared/parsers/point_class.dart';
import 'package:shared/parsers/xyz_parser.dart';

import '../cache.dart'; // for global variables

/*
    getUpload
    in: HttpRequest request {request containing csv file to download}
    out: response containing json points from parsed csv file
*/
Future<void> getUpload(HttpRequest request) async {

    // saving the sent file, and returning the points

    try {

        // Ensure upload directory exists
        final uploadDir = Directory('../../assets/uploads');

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

        if (filename == null) { // if empty filename
            request.response.statusCode = 400;
            request.response.write("File missing in form-data");
            await request.response.close();
            return;
        }

        // Save file
        final savePath = "../../assets/uploads/$filename";
        await File(savePath).writeAsBytes(fileBytes);
        print("File saved -> $savePath");

        // Parse CSV
        final points = await parseCustomPointCloud(savePath);

        cached_points = points;
        changed_points = true;

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

    } catch (e) { // if we errored out; logging because we are good boys

        print("UPLOAD FAILED: $e");
        request.response.statusCode = 500;
        request.response.write("Upload failed: $e");
        await request.response.close();

    }
}