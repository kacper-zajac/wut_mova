import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/video_converter.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:mova/views/video/video_item.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String _projectDirectory;
  final Function callback;

  VideoWidget(this._projectDirectory, this.callback);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  String? _currentVideoPath;
  VideoPlayerController? _videoPlayerController;
  bool _loading = false;

  setLoadingState(bool newState) {
    if (newState != _loading) {
      setState(() {
        _loading = newState;
        widget.callback(newState);
      });
    }
  }

  Future<void> getVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: false);

    if (result != null && result.files.single.path != null) {
      setLoadingState(true);

      VideoConverter converter = VideoConverter();
      converter.createVidCopy(context, result.files.single.path!, widget._projectDirectory);
    } else {
      setLoadingState(false);
    }
  }

  void initializePlayer(String filePath) {
    _currentVideoPath = filePath;
    _videoPlayerController = VideoPlayerController.file(File(filePath))..initialize();
  }

  Future<void> controllerChange(String filePath, bool isChanged) async {
    if (_videoPlayerController == null) {
      initializePlayer(filePath);
    } else if (isChanged) {
      await disposeVideoController();
      initializePlayer(filePath);

      setState(() {
        _loading = false;
        widget.callback(false);
      });
    }
  }

  Future<void> disposeVideoController() async {
    if (_videoPlayerController == null) return;
    final vpcToDispose = _videoPlayerController;

    _videoPlayerController = null;
    setLoadingState(false);

    vpcToDispose!.dispose();
    _currentVideoPath = null;
  }

  @override
  void dispose() {
    // disposeVideoController
    super.dispose();
  }

  void cleanProjectDirectory() async {
    Directory workDir = Directory(widget._projectDirectory + kWorkDirectoryName);
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
    bool isTranscriptInitialized =
        Provider.of<TranscribedWords>(context, listen: true).isInitialized;
    if (_filePath != null) {
      controllerChange(_filePath, Provider.of<VideoPath>(context, listen: false).isChanged);
      Future.delayed(
        Duration(milliseconds: 250),
        () => Provider.of<VideoPath>(context, listen: false).handleChange(),
      );
    }
    if (isTranscriptInitialized) {
      setLoadingState(false);
    }
    return _loading
        ? loadingView(context)
        : _videoPlayerController != null
            ? VideoItem(videoPlayerController: _videoPlayerController!)
            : isTranscriptInitialized
                ? Container(
                    height: 350.0,
                    width: 350.0,
                    child: ReusableTile(
                      isPadding: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : chooseVideoButton();
  }

  Expanded chooseVideoButton() {
    return Expanded(
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            onSurface: kBoxColorTop,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            primary: kBoxColorTop,
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
          ),
          onPressed: () async {
            await getVideo();
          },
          child: Text(
            'Choose a video',
            style: kBoxTextStyle,
          ),
        ),
      ),
    );
  }

  Expanded loadingView(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(
            height: 50.0,
          ),
          DefaultTextStyle(
            style: kBoxTextStyle.copyWith(fontSize: 12.0, color: Colors.white70),
            child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                TypewriterAnimatedText('your video is loading',
                    speed: Duration(
                      milliseconds: 220,
                    ),
                    curve: Curves.bounceIn,
                    cursor: ''),
                TypewriterAnimatedText('the transcript is being prepared',
                    speed: Duration(
                      milliseconds: 170,
                    ),
                    curve: Curves.slowMiddle,
                    cursor: ''),
                TypewriterAnimatedText('the audio is being adjusted',
                    speed: Duration(
                      milliseconds: 170,
                    ),
                    curve: Curves.ease,
                    cursor: ''),
                TypewriterAnimatedText('colors are being tweaked',
                    speed: Duration(
                      milliseconds: 220,
                    ),
                    curve: Curves.bounceIn,
                    cursor: ''),
                TypewriterAnimatedText('the translation is being refined',
                    speed: Duration(
                      milliseconds: 170,
                    ),
                    curve: Curves.ease,
                    cursor: ''),
                TypewriterAnimatedText('mova is thinking',
                    speed: Duration(
                      milliseconds: 200,
                    ),
                    cursor: ''),
                TypewriterAnimatedText('mova is thinking',
                    speed: Duration(
                      milliseconds: 210,
                    ),
                    cursor: ''),
                TypewriterAnimatedText('mova is thinking',
                    speed: Duration(
                      milliseconds: 220,
                    ),
                    cursor: ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
