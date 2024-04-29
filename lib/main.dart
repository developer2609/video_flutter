import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'HomePage.dart';
import 'list_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.firstWhere((camera) {
    return camera.lensDirection == CameraLensDirection.front;
  });

  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: ListScreen(),
  ));
}