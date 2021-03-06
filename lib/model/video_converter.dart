import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/speech_to_text.dart';
import 'package:mova/model/transcribed_word.dart';
import 'package:mova/provider/file_path.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class VideoConverter {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  Future<void> toMp3(BuildContext context, String path, String projectDirectory) async {
    String filePath = projectDirectory + kAudioFileName;
    if (File(filePath).existsSync()) File(filePath).deleteSync();
    await _flutterFFmpeg
        .execute("-i $path -q:a 0 -map a -filter:a \"volume=1.5\" $filePath")
        .then((_) {
      SpeechToText1().getTranscript(context, filePath, projectDirectory);
    });
  }

  Future<void> createThumbnail(String filePath, String projectDirectory) async {
    String thumbnailPath = projectDirectory + kThumbnailFileName;
    if (File(thumbnailPath).existsSync()) File(thumbnailPath).deleteSync();
    await _flutterFFmpeg
        .execute("-ss 00:00:00.000  -i $filePath -vframes 1 $thumbnailPath")
        .then((_) {});
  }

  Future<void> createVidCopy(BuildContext context, String path, String projectDirectory) async {
    String filePath = projectDirectory + kVideoFileName;
    if (File(filePath).existsSync()) File(filePath).deleteSync();
    await _flutterFFmpeg.execute("-i $path -vf scale=640:480 $filePath").then((_) async {
      Provider.of<VideoPath>(context, listen: false).setVideoPath(filePath);
      toMp3(context, filePath, projectDirectory);
      createThumbnail(filePath, projectDirectory);
    });
  }

  Future<String> extractChunk(
      int order, String workDir, String projDirectory, int chunkStartTime, int chunkEndTime) async {
    String videoPath = projDirectory + kVideoFileName;
    String filePath = workDir + '/temp' + order.toString() + '.mp4';
    String startTime = convertTimeToString(chunkStartTime);
    String endTime = convertTimeToString(chunkEndTime);
    await _flutterFFmpeg.execute("-ss $startTime -to $endTime -i $videoPath -c copy $filePath");
    return filePath;
  }

  Future<String> extractWord(TranscribedWord tw) async {
    String videoPath = tw.projectDirectory + kVideoFileName;
    String filePath = tw.projectDirectory +
        kWorkDirectoryName +
        '/' +
        ((tw.text == '_') ? kVideoBreakName : kVideoWordName) +
        '_' +
        tw.order.toString() +
        '.mp4';
    String startTime = convertTimeToString(tw.startTime);
    String endTime = convertTimeToString(tw.endTime);
    await _flutterFFmpeg.execute("-ss $startTime -to $endTime -i $videoPath -c copy $filePath");
    return filePath;
  }

  String convertTimeToString(int time) {
    double timeDouble = time / 1000000.0;
    int seconds = ((timeDouble - timeDouble.truncate()) * 1000).floor();
    int minutes = timeDouble.truncate();

    String stringTime = seconds < 100
        ? '00:00:0' + minutes.toString() + '.0' + seconds.toString()
        : '00:00:0' + minutes.toString() + '.' + seconds.toString();
    return stringTime;
  }

  Future<void> combineVideo(
      String projectDirectory, List<TranscribedWord> words, BuildContext context) async {
    String myPath = projectDirectory + kWorkDirectoryName + '/combined_' + kVideoWordName;

    String filePathTxt = myPath + '.txt';
    String filePath = myPath + '.mp4';

    if (File(filePathTxt).existsSync()) File(filePathTxt).deleteSync();
    if (File(filePath).existsSync()) File(filePath).deleteSync();

    String filesToConcat = '';
    for (TranscribedWord word in words) {
      if (filesToConcat != '') filesToConcat += '\n';
      filesToConcat += 'file \'' + await extractWord(word) + '\'';
    }
    final bytes = utf8.encode(filesToConcat);
    await File(filePathTxt).writeAsBytes(bytes);

    await _flutterFFmpeg
        .execute("-f concat -safe 0 -i $filePathTxt -c copy $filePath")
        .then((rc) async {
      if (rc == 0) {
        Provider.of<VideoPath>(context, listen: false).setVideoPath(filePath);
      }
    });
  }

  Future<void> exportVideo(
      String projectDirectory, List<TranscribedWord> words, BuildContext context) async {
    String buildDirPath = projectDirectory + kWorkDirectoryName + '/temp';

    Directory(buildDirPath).createSync();

    int? endTime;
    int? startTime;
    int order = 0;
    String filesToConcat = '';

    for (TranscribedWord tw in words) {
      print(tw.text);
      if (endTime == tw.startTime) {
        endTime = tw.endTime;
        continue;
      } else if (startTime == null) {
        startTime = tw.startTime;
        endTime = tw.endTime;
        continue;
      } else {
        if (filesToConcat != '') filesToConcat += '\n';
        filesToConcat += 'file \'' +
            await extractChunk(order++, buildDirPath, projectDirectory, startTime, endTime!) +
            '\'';
        startTime = tw.startTime;
        endTime = tw.endTime;
        continue;
      }
    }

    if (startTime != null) {
      if (filesToConcat != '') filesToConcat += '\n';
      filesToConcat += 'file \'' +
          await extractChunk(order++, buildDirPath, projectDirectory, startTime, endTime!) +
          '\'';
    }

    String filePathTxt = buildDirPath + '/temp_combined.txt';
    String filePath = projectDirectory + kWorkDirectoryName + '/exported.mp4';

    if (File(filePath).existsSync()) File(filePath).deleteSync();

    final bytes = utf8.encode(filesToConcat);
    await File(filePathTxt).writeAsBytes(bytes);

    await _flutterFFmpeg
        .execute("-f concat -safe 0 -i $filePathTxt -c copy $filePath")
        .then((rc) async {
      if (rc == 0) {
        Provider.of<VideoPath>(context, listen: false).setVideoPath(filePath);
      }
    });

    Directory(buildDirPath).deleteSync(recursive: true);
  }
}
