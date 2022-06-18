import 'package:flutter/material.dart';

class VideoPath with ChangeNotifier {
  String? _videoPath;
  String? _originalVideoPath;
  bool _isChanged = false;

  bool get isChanged => _isChanged;
  String? get videoPath => _videoPath;
  String? get originalVideoPath => _originalVideoPath;

  void setOriginalVideoPath(String val) {
    _originalVideoPath = val;
    print('Original set');
    print(val);
  }

  void setVideoPath(String? val){
    _isChanged = true;
    _videoPath = val;
    notifyListeners();
  }

  void handleChange() {
    _isChanged = false;
  }
}