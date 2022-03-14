import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoWidget extends StatelessWidget {
  String filePath;

  VideoWidget({required this.filePath});

  @override
  Widget build(BuildContext context) {
    VideoPlayerController _videoPlayerController =
        VideoPlayerController.file(File(filePath));

    return Container(
      child: Expanded(
        child: Chewie(
          controller: ChewieController(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            videoPlayerController: _videoPlayerController,
          ),
        ),
      ),
    );
  }
}
