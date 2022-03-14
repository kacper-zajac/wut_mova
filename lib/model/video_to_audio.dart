import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class VideoToSpeechConverter{
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  Future<String> toMp3(String path) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = dir.path + '/out_audio.wav';
    print(filePath);
    await _flutterFFmpeg.execute("-i $path $filePath").then((rc) =>
        print("FFmpeg process exited with rc $rc"));
    return filePath;
  }
}