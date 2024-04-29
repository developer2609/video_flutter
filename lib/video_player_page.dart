import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeControllerFuture;
  late StreamSubscription<Duration> _positionSubscription;
  late Duration _currentPosition=Duration.zero;
  int currentDurationInSecond = 0;
  int _playCount = 0;


  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeControllerFuture = _controller.initialize();
    _currentPosition = Duration.zero;

    // Set up position stream to emit position updates
    _positionSubscription = Stream.periodic(Duration(milliseconds: 500), (_) => _controller.value.position)
        .listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _positionSubscription.cancel();
    super.dispose();
  }

  void _seekVideo(Duration position) {
    _controller.seekTo(position);
  }
  void _playVideo() {
    _controller.play();
    _playCount++;
    if (_playCount == 1) {
      // Pause the video twice after the first play
      _controller.pause();
      Future.delayed(Duration(seconds: 1), () {
        if (_playCount == 1) {
          _controller.pause();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video player screen')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    children: [
                      VideoPlayer(_controller),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child:
                        VideoProgressIndicator(_controller, allowScrubbing: true,
                          colors: VideoProgressColors(
                              playedColor: Colors.blue,
                              bufferedColor: Colors.white,
                              backgroundColor: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds - 10));
                  });
                },
                icon: Icon(Icons.fast_rewind),
              ),
              IconButton(
                onPressed:
                    () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds + 10));
                  });
                },
                icon: Icon(Icons.fast_forward),
              ),
            ],
          ),
          Text(
            '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / ${_controller.value.duration?.inMinutes}:${(_controller.value.duration!.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
