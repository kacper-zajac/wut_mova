import 'package:flutter/material.dart';

class VideoPath with ChangeNotifier {
  String? _videoPath;

  String? get videoPath => _videoPath;

  void setVideoPath(String? val){
    _videoPath = val;
    notifyListeners();
  }
}
//
// class AudioPath with ChangeNotifier {
//   String? _audioPath;
//
//   String? get audioPath => _audioPath;
//
//   void setAudioPath(String? val){
//     _audioPath = val;
//     notifyListeners();
//   }
// }