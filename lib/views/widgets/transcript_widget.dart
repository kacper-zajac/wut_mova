import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:provider/provider.dart';
import 'package:mova/views/widgets/transcribed_word_widget.dart';

import '../../model/transcribed_word.dart';
import '../../model/video_converter.dart';

class TranscriptWidget extends StatefulWidget {
  final String projectDirectory;

  TranscriptWidget(this.projectDirectory);

  @override
  State<TranscriptWidget> createState() => _TranscriptWidgetState();
}

class _TranscriptWidgetState extends State<TranscriptWidget> {
  late List<TranscribedWord> _transcribedWords = [];

  List<TranscribedWordWidget> getTranscript() {
    List<TranscribedWordWidget> transcribedWordWidgets = [];
    setState(() {
      for (TranscribedWord tw in _transcribedWords) {
        transcribedWordWidgets
            .add(TranscribedWordWidget(transcribedWidget: tw));
      }
    });
    return transcribedWordWidgets;
  }

  @override
  Widget build(BuildContext context) {
    _transcribedWords =
        Provider.of<TranscribedWords>(context, listen: true).transcribedWords;
    if (_transcribedWords.isNotEmpty) {
      return Expanded(
        child: SizedBox(
          height: 150.0,
          child: Column(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: getTranscript(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => VideoConverter().combineVideo(
                        widget.projectDirectory, _transcribedWords, context),
                    child: const Text('refresh'),
                  ),
                  TextButton(
                    onPressed: () => VideoConverter().exportVideo(
                        widget.projectDirectory, _transcribedWords, context),
                    child: const Text('export'),
                  ),
                ],
              ),
            ],
          ),
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
