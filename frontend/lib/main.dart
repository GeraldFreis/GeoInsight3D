import 'package:flutter/material.dart';
import './3d_viewer.dart';
import './fetchers.dart'; // fetchPointCloud method
import 'package:shared/parsers/point_class.dart';


// void main() async {

//   WidgetsFlutterBinding.ensureInitialized();
//   final points = await fetchPointCloud(); // From backend
//   final classes = await fetchClasses();
//   print(points);
// }// import 'package:flutter/material.dart';
// import './3d_viewer.dart';
// import './fetchers.dart'; // fetchPointCloud method


// void main() async {

//   WidgetsFlutterBinding.ensureInitialized();
//   final points = await fetchPointCloud(); // From backend
//   final classes = await fetchClasses();
//   print(points);
// }
import 'package:flutter/material.dart';

import './viewer.dart';
import './fetchers.dart';
import 'package:shared/parsers/point_class.dart';

// IMPORTANT WEB IMPORTS
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GeoInsight3D",
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<PointXYZ>? points;

  // for when someone wants to visualise certain classes
  List<String>? point_classes;
  String? selected_class;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  Future<void> loadPoints() async {
    setState(() => loading = true);

    try {

      final fetched = await fetchPointCloud();
      final classes = await fetchClasses();

      setState(() {

        points = fetched;
        point_classes = classes;

        loading = false;

      });

    } catch (e) {

      print("Error fetching points: $e");
      setState(() => loading = false);

    }

  }

  // ---------------------------------------------------------------------------
  // Upload CSV → POST to backend → Backend stores → Reload pointcloud
  // ---------------------------------------------------------------------------
  Future<void> uploadCsv() async {
    final input = html.FileUploadInputElement()..accept = ".csv";
    input.click();

    input.onChange.listen((event) async {
      final file = input.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoad.first;

      final bytes = reader.result as Uint8List;

      // Create multipart POST
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("http://localhost:8080/upload"),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          bytes,
          filename: file.name,
          contentType: MediaType("text", "csv"),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        await loadPoints();
      } else {
        print("Upload failed");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TOP NAVBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "GeoInsight3D",
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.blue),
            onPressed: uploadCsv,
          ), DropdownButton<String>(
              value: selected_class,
              hint: const Text("Select class to highlight"),
              items: const [
                DropdownMenuItem(value: "Low", child: Text("Low lying land")),
                DropdownMenuItem(value: "High", child: Text("High land")),
                DropdownMenuItem(value: "Inconsequential", child: Text("Inconsequential")),
                DropdownMenuItem(value: "Building", child: Text("Building")),
                DropdownMenuItem(value: "Trees", child: Text("Trees")),
              ],
              onChanged: (value) {
                setState(() {
                  selected_class = value;
                  
                });
              },
            ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text("Reload Pointcloud"),
              onTap: loadPoints,
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Upload CSV"),
              onTap: uploadCsv,
            ),
          ],
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : points == null
              ? const Center(child: Text("No points loaded"))
              : PointCloudViewer(points: points!, point_classes: point_classes, highlight_class: selected_class,),
    );
  }
}