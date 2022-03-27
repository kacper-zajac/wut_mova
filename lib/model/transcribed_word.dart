import 'dart:io';
import 'package:mova/model/video_converter.dart';

class TranscribedWord {
  TranscribedWord({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.order,
    required this.projectName
  }) {
    initFile();
  }

  Future<void> initFile() async {
    videoFile = File(await VideoConverter().extractWord(this));
  }

  final int order;
  final int startTime;
  final int endTime;
  final String text;
  final String projectName;
  late File videoFile;
}
