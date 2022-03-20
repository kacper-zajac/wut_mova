import 'package:flutter/material.dart';

class FilePath with ChangeNotifier {
  String? _videoPath;

  String? get videoPath => _videoPath;

  void setVideoPath(String? val){
    _videoPath = val;
    print(_videoPath);
    notifyListeners();
  }
}