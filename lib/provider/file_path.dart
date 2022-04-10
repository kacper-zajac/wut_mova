import 'package:flutter/material.dart';

class VideoPath with ChangeNotifier {
  String? _videoPath;
  bool _isChanged = false;

  bool get isChanged => _isChanged;
  String? get videoPath => _videoPath;

  void setVideoPath(String? val){
    _videoPath = val;
    _isChanged = true;
    notifyListeners();
  }

  void handleChange() {
    _isChanged = false;
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