import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/views/widgets/video_item.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoWidget extends StatefulWidget {
  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  List<VideoPlayerController> _videoPlayerController = [];
  bool _loading = false;
  late String _filePath;

  Future<void> getVideo() async {
    setState(() {
      _loading = true;
    });

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: false);

    if (result != null && result.files.single.path != null) {
      _filePath = result.files.single.path!;
      print(_filePath);
      Provider.of<FilePath>(context, listen: false).setVideoPath(_filePath);
      _videoPlayerController.add(VideoPlayerController.file(File(_filePath)));
      _videoPlayerController.first.initialize();
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: Container(
              child: _videoPlayerController.length == 1
                  ? VideoItem(videoPlayerController: _videoPlayerController.first)
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
                  _videoPlayerController.first.dispose();
                  setState(() {
                    _videoPlayerController.removeAt(0);
                  });
                  Provider.of<FilePath>(context, listen: false)
                      .setVideoPath(null);
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
