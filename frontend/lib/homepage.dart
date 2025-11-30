/*
 homepage.dart contains homepage classes used for creating the web app and displaying content
 contains:
    Class HomePage
        loadPoints (async) retrieving points & classes of points from cache in backend 
        uploadCsv (async) triggered when new csv uploaded, sends to backend
*/
import './fetchers.dart'; // for api calls
import 'package:flutter/material.dart';
import 'package:shared/parsers/point_class.dart';
import './viewer.dart';

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

    // loading the required points and classes from the fetchers
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


    Future<void> uploadCsv() async {

        final success = await sendCSV();

        if (success) {
            await loadPoints();
        } else {
            print("Upload failed");
        }

    }

    @override
    Widget build(BuildContext context) {

        return Scaffold(
        
        // nav bar
        appBar: AppBar(

            backgroundColor: Colors.white,
            title: const Text(
            "GeoInsight3D",
            style: TextStyle(color: Colors.blue),
            ),

            actions: [

            IconButton( // uploading the csv button
                icon: const Icon(Icons.upload_file, color: Colors.blue),
                onPressed: uploadCsv, 
            ), 
            DropdownButton<String>( // classes for user to choose from, to highlight features of map

                value: selected_class,
                hint: const Text("Select class to highlight"),
                items: const [

                    DropdownMenuItem(value: "Low", child: Text("Low lying land")),
                    DropdownMenuItem(value: "High", child: Text("High land")),
                    DropdownMenuItem(value: "Inconsequential", child: Text("Inconsequential")),
                    DropdownMenuItem(value: "Building", child: Text("Building")),

                ],

                onChanged: (value) {
                    setState(() {

                    selected_class = value;
                    
                    });
                },
                ),
            ],
        ),

        // left menu 
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

        // the actual points
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : points == null
                ? const Center(child: Text("No points loaded"))
                : PointCloudViewer(points: points!, point_classes: point_classes, highlight_class: selected_class,),
        );
    }
}