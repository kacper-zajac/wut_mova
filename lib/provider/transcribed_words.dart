import 'package:flutter/material.dart';
import 'package:mova/model/transcribed_word.dart';

class TranscribedWords with ChangeNotifier {
  final List<TranscribedWord> _transcribedWords = [];

  List<TranscribedWord> get transcribedWords => _transcribedWords;

  void addWord(TranscribedWord tw) {
    if (_transcribedWords.isNotEmpty &&
        _transcribedWords.last.endTime != tw.startTime) {
      _transcribedWords.add(TranscribedWord(
          text: '_',
          startTime: _transcribedWords.last.endTime,
          endTime: tw.startTime,
          order: tw.order,
          projectDirectory: tw.projectDirectory));
    }
    _transcribedWords.add(tw);
  }

  void deleteWord(TranscribedWord twToDelete) {
    int duration = twToDelete.endTime - twToDelete.startTime;
    _transcribedWords.remove(twToDelete);
    for (TranscribedWord tw in _transcribedWords) {
      if (tw.currentStartTime > twToDelete.currentStartTime) {
        tw.currentStartTime -= duration;
        tw.currentEndTime -= duration;
      }
    }
    notifyListeners();
  }

  void clearList() {
    _transcribedWords.clear();
  }

  void runNotifyListeners() {
    notifyListeners();
  }
}
