import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/speech_to_text.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:provider/provider.dart';
import 'package:mova/views/widgets/transcribed_word_widget.dart';

import '../../model/transcribed_word.dart';

class TranscriptWidget extends StatefulWidget {
  final String projectName;

  TranscriptWidget(this.projectName);

  @override
  State<TranscriptWidget> createState() => _TranscriptWidgetState();
}

class _TranscriptWidgetState extends State<TranscriptWidget> {
  late List<TranscribedWord>? _transcribedWords;
  late String? _videoPath;

  List<TranscribedWordWidget> getTranscript() {
    List<TranscribedWordWidget> transcribedWordWidgets = [];
    setState(() {
      for (TranscribedWord tw in _transcribedWords!) {
        transcribedWordWidgets.add(
            TranscribedWordWidget(transcribedWidget: tw));
      }
    });
    return transcribedWordWidgets;
  }

  @override
  Widget build(BuildContext context) {
    _transcribedWords =
        Provider.of<TranscribedWords>(context, listen: true).transcribedWords;
    _videoPath = Provider.of<VideoPath>(context, listen: true).videoPath;
    print(_transcribedWords);
    if (_transcribedWords!.isNotEmpty) {
      return Expanded(
        child: SizedBox(
          height: 150.0,
          child: Center(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.start,
                children: getTranscript(),
              ),
            ),
          ),
        ),
      );
    } else if (_videoPath != null) {
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
