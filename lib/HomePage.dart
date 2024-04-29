import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VideoRecorderScreen extends StatefulWidget {
  final CameraDescription camera;

  const VideoRecorderScreen({
    super.key,
    required this.camera,
  }) ;

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  late String _videoPath;


  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _elapsedSeconds += 1;
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Recorder')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CameraPreview(_controller),
                      if (_isRecording)
                        Positioned(
                          bottom: 16,
                          child: Text(
                            'Elapsed Time: $_elapsedSeconds seconds',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: _isRecording ? stopRecording : startRecording,
                  child: Icon(_isRecording ? Icons.stop : Icons.circle),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void startRecording() async {
    try {
      await _initializeControllerFuture;
      await _controller.prepareForVideoRecording();
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
        startTimer();
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  void stopRecording() async {
    try {
      // Stop video recording and get the recorded video file
      XFile? videoFile = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      if (videoFile != null) {
        // If a video file was successfully recorded
        _videoPath = videoFile.path;

        // Return to the previous screen with the video path
        Navigator.pop(context, _videoPath);
      } else {
        // Handle case when video recording failed
        print('Error: Video recording failed.');
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }}
