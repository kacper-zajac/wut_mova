import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mova/views/widgets/video_item.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  static const id = 'videoscreen';

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool _loaded = false;
  bool _loading = false;
  late VideoPlayerController _videoPlayerController;

  Future<void> getVideo() async {
    setState(() {
      _loading = true;
    });
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: false);
    if (result != null && result.files.single.path != null) {
      _videoPlayerController =
          VideoPlayerController.file(File(result.files.single.path!));
      _videoPlayerController.initialize();

      setState(() {
        _loaded = true;
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('video testing')),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              child: _loaded != false
                  ? VideoItem(videoPlayerController: _videoPlayerController)
                  : (_loading == false
                      ? TextButton(
                          onPressed: () {
                            getVideo();
                          },
                          child: const Text('Choose a video'),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        )),
            ),
          ),
          Expanded(
            child: Container(
              child: TextButton(
                onPressed: () {
                  try {
                    _videoPlayerController.dispose();
                  } catch (e) {
                    print(e);
                  }
                  setState(() {
                    _loading = false;
                    _loaded = false;
                  });
                },
                child: const Text('reset'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
