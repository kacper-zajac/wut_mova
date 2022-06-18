import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mova/provider/video_timer.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  const VideoItem({required this.videoPlayerController, Key? key}) : super(key: key);

  final VideoPlayerController videoPlayerController;

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      aspectRatio: 1/1,
      videoPlayerController: widget.videoPlayerController,
      autoInitialize: false,
      errorBuilder: (context, errorMessage) {
        return Utils.centeredText(
          text: 'Something went wrong. Please try again! ($errorMessage)',
          style: const TextStyle(color: Colors.white),
        );
      },
    );
    widget.videoPlayerController.addListener(() {
      Provider.of<VideoTimer>(context, listen: false).setTime(
          widget.videoPlayerController.value.position.inSeconds,
          widget.videoPlayerController.value.position.inMicroseconds);
    });
  }

  @override
  void dispose() {
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350.0,
      width: 350.0,
      child: ReusableTile(
        isPadding: false,
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }
}
