import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/speech_to_text.dart';
import 'package:mova/model/video_to_audio.dart';
import 'package:mova/provider/file_path.dart';
import 'package:provider/provider.dart';
import 'package:mova/views/widgets/transcribed_word_widget.dart';

class TranscriptWidget extends StatefulWidget {
  @override
  State<TranscriptWidget> createState() => _TranscriptWidgetState();
}

class _TranscriptWidgetState extends State<TranscriptWidget> {
  SpeechToText1 stt = SpeechToText1();

  late String? _filePath;

  List<TranscribedWordWidget> transcribedWords = [];

  Future<void> getTranscript() async {
    await stt.init();
    VideoToSpeechConverter vtsc = VideoToSpeechConverter();
    String wavPath = await vtsc.toMp3(_filePath!);
    await stt.getTranscript(transcribedWords,
        '/data/user/0/pl.kacperzajac.mova/app_flutter/out_audio.wav');
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    _filePath = Provider.of<FilePath>(context, listen: true).videoPath;
    if (transcribedWords.isNotEmpty && _filePath != null) {
      return Expanded(
        child: SizedBox(
          height: 150.0,
          child: Center(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.start,
                children: transcribedWords,
              ),
            ),
          ),
        ),
      );
    } else if (_filePath != null) {
      getTranscript();
      return const Center(
        child: Text(
          'The transcript is generating',
          style: kBoxBottomTextStyle,
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Waiting for an input',
          style: kBoxBottomTextStyle,
        ),
      );
    }
  }
}
