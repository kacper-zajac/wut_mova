import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/video_converter.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:mova/views/widgets/video_item.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoWidget extends StatefulWidget {
  final String _projectDirectory;

  VideoWidget(this._projectDirectory);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  String? _currentVideoPath;
  VideoPlayerController? _videoPlayerController;
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
          context, result.files.single.path!, widget._projectDirectory);
    }
  }

  void initializePlayer(String filePath) {
    _currentVideoPath = filePath;
    _videoPlayerController = VideoPlayerController.file(File(filePath))
      ..initialize().then((value) => setState(() {
            _loading = false;
          }));
  }

  Future<void> controllerChange(String filePath, bool isChanged) async {
    if (_videoPlayerController == null) {
      initializePlayer(filePath);
    } else if (isChanged) {
      final oldPlayer = _videoPlayerController;
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        await oldPlayer!.dispose();

        initializePlayer(filePath);
      });

      setState(() {
        _loading = false;
        _videoPlayerController = null;
        _currentVideoPath = filePath;
      });
    }
  }

  Future<void> disposeVideoController() async {
    if (_videoPlayerController == null) return;
    final vpcToDispose = _videoPlayerController;
    setState(() {
      _loading = false;
      _videoPlayerController = null;
    });
    vpcToDispose!.dispose();
    _currentVideoPath = null;
  }

  void cleanProjectDirectory() async {
    Directory workDir =
        Directory(widget._projectDirectory + '/' + kWorkDirectoryName);
    Directory projDir = Directory(widget._projectDirectory);
    final List<FileSystemEntity> entities = await projDir.list().toList();
    final Iterable<File> files = entities.whereType<File>();
    for (final file in files) {
      if (!file.path.contains('config')) {
        file.deleteSync(recursive: false);
      }
    }
    if (workDir.existsSync()) {
      workDir.deleteSync(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? _filePath = Provider.of<VideoPath>(context, listen: true).videoPath;
    if (_filePath != null) {
      controllerChange(
          _filePath, Provider.of<VideoPath>(context, listen: false).isChanged);
      Provider.of<VideoPath>(context, listen: false).handleChange();
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: Container(
              child: _videoPlayerController != null
                  ? VideoItem(videoPlayerController: _videoPlayerController!)
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: () {
                    if (_currentVideoPath != null) {
                      cleanProjectDirectory();
                      disposeVideoController();
                      Provider.of<VideoPath>(context, listen: false)
                          .setVideoPath(null);
                      Provider.of<TranscribedWords>(context, listen: false)
                          .clearList();
                      Provider.of<TranscribedWords>(context, listen: false)
                          .runNotifyListeners();
                    }
                  },
                  child: const Text('reset / get new video'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
