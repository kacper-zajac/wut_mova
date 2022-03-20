import 'package:flutter/material.dart';

class VideoTimer with ChangeNotifier {
  bool isPlaying = true;
  int? _microSeconds;
  int? _seconds;

  int? get seconds {
    return _seconds;
  }

  int? get microSeconds {
    return _microSeconds;
  }

  void setTime(int sec, int micro) {
    _seconds = sec;
    _microSeconds = micro;
    notifyListeners();
  }
}
