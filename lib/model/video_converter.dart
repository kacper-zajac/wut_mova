import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/speech_to_text.dart';
import 'package:mova/model/transcribed_word.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../constants.dart';

class VideoConverter {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();

  Future<void> toMp3(BuildContext context, String path, String projectDirectory) async {
    String filePath = projectDirectory + kAudioFileName;
    if (File(filePath).existsSync()) File(filePath).deleteSync();
    await _flutterFFmpeg
        .execute(
            "-i $path -vn -acodec pcm_s16le -ar 44100 -ac 1 -filter:a \"volume=2.0\" $filePath")
        .then((_) async {
      await _flutterFFprobe.getMediaInformation(path).then((info) async {
        await SpeechToText1().getTranscript(
            context,
            filePath,
            projectDirectory,
            info.getMediaProperties() == null
                ? 0.0
                : double.parse(info.getMediaProperties()!['duration']));
      });
    });
  }

  Future<void> createThumbnail(String filePath, String projectDirectory) async {
    String thumbnailPath = projectDirectory + kThumbnailFileName;
    if (File(thumbnailPath).existsSync()) File(thumbnailPath).deleteSync();
    await _flutterFFmpeg
        .execute("-ss 00:00:00.000 -i $filePath -vframes 1 $thumbnailPath")
        .then((_) {});
  }

  Future<void> createVidCopy(BuildContext context, String path, String projectDirectory) async {
    String filePath = projectDirectory + kVideoFileName;
    String originalCopyPath =
        projectDirectory + kOriginalCopyFileName + path.substring(path.lastIndexOf('.'));

    if (File(originalCopyPath).existsSync()) File(originalCopyPath).deleteSync();
    if (File(filePath).existsSync()) File(filePath).deleteSync();

    await _flutterFFmpeg.execute("-i $path -map 0:a -map 0:v -c copy -crf 27 -preset veryfast $originalCopyPath").then((rc) async {
      if (rc == 0) {
        Provider.of<VideoPath>(context, listen: false).setOriginalVideoPath(originalCopyPath);
      } else {
        if (await Utils.showErrorDialog(
            context, 'Unidentified error occurred. Please try again.') ??
            false) {
          Navigator.of(context).pop();
        }
    });

    await _flutterFFmpeg
        .execute("-i $originalCopyPath -vf scale=640:480 -r 60 -crf 27 -preset veryfast $filePath")
        .then((rc) async {
      if (rc == 0) {
        await toMp3(context, filePath, projectDirectory);
        Provider.of<VideoPath>(context, listen: false).setVideoPath(filePath);
        await createThumbnail(filePath, projectDirectory);
      } else {
        if (await Utils.showErrorDialog(
                context, 'Unidentified error occurred. Please try again.') ??
            false) {
          Navigator.of(context).pop();
        }
        _flutterFFmpeg.cancel();
      }
    });
  }

  Future<String> extractChunk(
      int order, String workDir, String projDirectory, int chunkStartTime, int chunkEndTime) async {
    String videoPath = projDirectory + kVideoFileName;
    String filePath = workDir + '/temp' + order.toString() + '.mp4';
    String startTime = convertTimeToString(chunkStartTime);
    String endTime = convertTimeToString(chunkEndTime);
    await _flutterFFmpeg.execute("-ss $startTime -to $endTime -i $videoPath -map 0:a -map 0:v -crf 27 -preset veryfast $filePath");
    return filePath;
  }

  Future<String> extractChunkCustomPath(int order, String fileName, String fileExtension,
      String workDir, String projDirectory, int chunkStartTime, int chunkEndTime) async {
    String videoPath = fileName;
    String filePath = workDir + '/temp' + order.toString() + fileExtension;
    String startTime = convertTimeToString(chunkStartTime);
    String endTime = convertTimeToString(chunkEndTime);
    await _flutterFFmpeg.execute("-ss $startTime -to $endTime -i $videoPath -map 0:a -map 0:v -crf 27 -preset veryfast $filePath");
    return filePath;
  }

  // Future<String> extractWord(TranscribedWord tw) async {
  //   String videoPath = tw.projectDirectory + kVideoFileName;
  //   String filePath = tw.projectDirectory +
  //       kWorkDirectoryName +
  //       '/' +
  //       ((tw.text == '_') ? kVideoBreakName : kVideoWordName) +
  //       '_' +
  //       tw.order.toString() +
  //       '.mp4';
  //   String startTime = convertTimeToString(tw.startTime);
  //   String endTime = convertTimeToString(tw.endTime);
  //   await _flutterFFmpeg.execute("-ss $startTime -to $endTime -i $videoPath -c copy $filePath");
  //   return filePath;
  // }

  String convertTimeToString(int time) {
    double timeDouble = time / 1000000.0;

    int s = timeDouble.truncate();
    int ms = ((timeDouble - s) * 1000).round();

    String msString = ms < 100 ? '.0' + ms.toString() : '.' + ms.toString();
    String sString = s < 10 ? ':0' + s.toString() : ':' + s.toString();

    return '00:00' + sString + msString;
  }

  Future<void> exportVideo(RoundedLoadingButtonController controller, String projectDirectory,
      List<TranscribedWord> words, BuildContext context) async {
    var fileName = Provider.of<VideoPath>(context, listen: false).originalVideoPath;
    var exportedFilePath = await combineVideoOriginal(projectDirectory, words, fileName!);
    if (exportedFilePath != 'Error') {
      await GallerySaver.saveVideo(exportedFilePath, albumName: 'Mova').then((bool? success) {
        if (success != null && success) {
          controller.success();
        } else {
          controller.error();
        }
      });
    } else {
      controller.error();
    }
  }

  Future<void> combineVideo(
      String projectDirectory, List<TranscribedWord> words, BuildContext context) async {
    String buildDirPath = projectDirectory + kWorkDirectoryName + '/temp';

    Directory(buildDirPath).createSync();

    int? endTime;
    int? startTime;
    int order = 0;
    String filesToConcat = '';

    for (TranscribedWord tw in words) {
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
        .execute("-f concat -safe 0 -i $filePathTxt -map 0:a -map 0:v -c copy $filePath")
        .then((rc) async {
      if (rc == 0) {
        Provider.of<VideoPath>(context, listen: false).setVideoPath(filePath);
      }
    });

    Directory(buildDirPath).deleteSync(recursive: true);
  }

  Future<String> combineVideoOriginal(
      String projectDirectory, List<TranscribedWord> words, String originalFilePath) async {
    try {
      String buildDirPath = projectDirectory + kWorkDirectoryName + '/temp';
      Directory(buildDirPath).createSync();

      String fileExtension = originalFilePath.lastIndexOf('.') == -1
          ? '.mp4'
          : originalFilePath.substring(originalFilePath.lastIndexOf('.'));

      int? endTime;
      int? startTime;
      int order = 0;
      String filesToConcat = '';

      for (TranscribedWord tw in words) {
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
              await extractChunkCustomPath(order++, originalFilePath, fileExtension, buildDirPath,
                  projectDirectory, startTime, endTime!) +
              '\'';
          startTime = tw.startTime;
          endTime = tw.endTime;
          continue;
        }
      }

      if (startTime != null) {
        if (filesToConcat != '') filesToConcat += '\n';
        filesToConcat += 'file \'' +
            await extractChunkCustomPath(order++, originalFilePath, fileExtension, buildDirPath,
                projectDirectory, startTime, endTime!) +
            '\'';
      }
      String filePathTxt = buildDirPath + '/temp_combined.txt';
      String filePath = projectDirectory + kWorkDirectoryName + '/export_original' + fileExtension;

      if (File(filePath).existsSync()) File(filePath).deleteSync();

      final bytes = utf8.encode(filesToConcat);
      await File(filePathTxt).writeAsBytes(bytes);
      await _flutterFFmpeg
          .execute("-f concat -safe 0 -i $filePathTxt -map 0:a -map 0:v -c copy $filePath")
          .then((rc) async {
        if (rc == 1) throw Exception('Video not created');
      });

      Directory(buildDirPath).deleteSync(recursive: true);

      return filePath;
    } catch (e) {
      return 'Error';
    }
  }
}
