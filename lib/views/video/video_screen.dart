import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/speech_to_text.dart';
import 'package:mova/model/transcribed_word.dart';
import 'package:mova/model/video_to_audio.dart';
import 'package:mova/views/widgets/video_item.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  static const id = 'videoscreen';

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List<TranscribedWord> transcribedWords = [];
  bool _loaded = false;
  bool _loading = false;
  String _transcript = '';
  SpeechToText1 stt = SpeechToText1();
  String? _filePath;
  late VideoPlayerController _videoPlayerController;

  Future<void> getTranscript() async {
    await stt.init();

    VideoToSpeechConverter vtsc = VideoToSpeechConverter();
    String wavPath = await vtsc.toMp3(_filePath!);
    await stt.getTranscript(transcribedWords,
        '/data/user/0/pl.kacperzajac.mova/app_flutter/out_audio.wav');
    setState(() {
      print(_transcript);
    });
  }

  Future<void> getVideo() async {
    setState(() {
      _loading = true;
    });
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: false);
    if (result != null && result.files.single.path != null) {
      _filePath = result.files.single.path;
      _videoPlayerController = VideoPlayerController.file(File(_filePath!));
      _videoPlayerController.initialize();

      setState(() {
        _loaded = true;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              child: _loaded != false
                  ? VideoItem(videoPlayerController: _videoPlayerController)
                  : (_loading == false
                      ? TextButton(
                          onPressed: () async {
                            await getVideo();
                            getTranscript();
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
              height: 150.0,
              child: Center(
                  child: Text(_transcript, style: kBoxTextStyle, textAlign: TextAlign.center,),
              ),
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
                    _transcript = '';
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
