import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_flutter/video_player_page.dart';

import 'HomePage.dart'; // Import the VideoPlayerScreen

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<String> savedVideos = []; // List to store saved video paths
  late List<CameraDescription> cameras; // List of available cameras

  @override
  void initState() {
    super.initState();
    initializeCameras();
  }

  Future<void> initializeCameras() async {
    cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('List of Videos',),
       backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: savedVideos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.blue,
              child: ListTile(
                title: Text('Video ${index + 1}',style: TextStyle(color: Colors.black),),
                leading: Icon(Icons.video_camera_back),
                onTap: () {
                  // Navigate to VideoPlayerScreen when a saved video is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(videoPath: savedVideos[index]),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (cameras.isNotEmpty) {
            // Navigate to VideoRecorderScreen when FloatingActionButton is pressed
            final videoPath = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoRecorderScreen(camera: cameras.last),
              ),
            );

            // Update savedVideos list if videoPath is not null
            if (videoPath != null && videoPath is String) {
              setState(() {
                savedVideos.add(videoPath);
              });
            }
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
