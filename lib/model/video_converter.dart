import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/material.dart';
import 'package:mova/model/speech_to_text.dart';
import 'package:mova/model/transcribed_word.dart';
import 'package:mova/provider/file_path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:mova/constants.dart';

import '../constants.dart';

class VideoConverter {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  Future<void> toMp3(
      BuildContext context, String path, String projectName) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = dir.path + '/' + projectName + '/' + kAudioFileName;
    await _flutterFFmpeg
        .execute("-i $path -q:a 0 -map a -filter:a \"volume=1.5\" $filePath")
        .then((_) {
          SpeechToText1().getTranscript(context, filePath, projectName);
    });
  }

  Future<String> createVidCopy(
      BuildContext context, String path, String projectName) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = dir.path + '/' + projectName + '/' + kVideoFileName;
    await _flutterFFmpeg
        .execute("-i $path -vf scale=640:480 $filePath")
        .then((_) async {
      Provider.of<VideoPath>(context, listen: false).setVideoPath(filePath);
      toMp3(context, filePath, projectName);
    });
    return filePath;
  }

  Future<String> extractWord(TranscribedWord tw) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String videoPath = dir.path + '/' + tw.projectName + '/' + kVideoFileName;
    String filePath = dir.path +
        '/' +
        tw.projectName +
        '/' +
        kWorkDirectoryName +
        '/' +
        kVideoWordName +
        '_' +
        tw.order.toString() +
        '.mp4';
    String startTime = convertTimeToString(tw.startTime);
    String endTime = convertTimeToString(tw.endTime);
    await _flutterFFmpeg.execute(
        "-i $videoPath -ss $startTime -t $endTime -c:v copy -c:a copy $filePath");
    return filePath;
  }

  String convertTimeToString(int time) {
    double seconds = (time / 1000000) % 60;
    int minutes = (seconds / 60).floor();
    String stringTime =
        '00:' + minutes.toString() + ':' + seconds.toStringAsFixed(3);
    return stringTime;
  }
//
// Future<void> extractWord(List<TranscribedWordWidget> transcribedWords,
//     String projectName, String videoPath) async {
//   File videoFile = File(videoPath);
//   await _trimmer.loadVideo(videoFile: videoFile);
//   Directory dir = await getApplicationDocumentsDirectory();
//   await Directory(dir.path + '/' + projectName + '/' + workDirectoryName)
//       .create()
//       .then((Directory dir) {
//     for (TranscribedWordWidget tw in transcribedWords) {
//       String filePath = dir.path + '/word_' + tw.order.toString() + '.mp4';
//       _trimmer.saveTrimmedVideo(
//           startValue: tw.startTime.toDouble() / 1000,
//           endValue: tw.endTime.toDouble() / 1000,
//           // videoFileName: ,
//           // videoFolderName: ,
//           storageDir: StorageDir.applicationDocumentsDirectory);
//     }
//   });
}
