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