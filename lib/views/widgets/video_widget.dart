import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mova/model/video_converter.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/views/widgets/video_item.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoWidget extends StatefulWidget {
  final String projectName;

  VideoWidget(this.projectName);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  List<VideoPlayerController> _videoPlayerController = [];
  bool _loading = false;

  Future<void> getVideo() async {
    setState(() {
      _loading = true;
    });

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: false);

    if (result != null && result.files.single.path != null) {
      VideoConverter converter = VideoConverter();
      converter.createVidCopy(
          context, result.files.single.path!, widget.projectName);
    }
  }

  void initializePlayer(String filePath) {
    _videoPlayerController.add(VideoPlayerController.file(File(filePath)));
    _videoPlayerController.first.initialize();

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? _filePath = Provider.of<VideoPath>(context, listen: true).videoPath;
    if(_filePath != null && _videoPlayerController.isEmpty) {
      initializePlayer(_filePath);
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: Container(
              child: _videoPlayerController.length == 1
                  ? VideoItem(
                      videoPlayerController: _videoPlayerController.first)
                  : (_loading == false
                      ? TextButton(
                          onPressed: () async {
                            await getVideo();
                          },
                          child: const Text('Choose a video'),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        )),
            ),
          ),
          Flexible(
            child: Container(
              child: TextButton(
                onPressed: () {
                  if (_videoPlayerController.isNotEmpty) {
                    _videoPlayerController.first.dispose();
                    setState(() {
                      _loading = false;

                      _videoPlayerController
                          .remove(_videoPlayerController.first);
                    });
                    File(_filePath!).delete();
                    Provider.of<VideoPath>(context, listen: false)
                        .setVideoPath(null);
                  }
                },
                child: const Text('reset'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
