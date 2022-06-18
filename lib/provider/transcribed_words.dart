import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mova/model/transcribed_word.dart';

class TranscribedWords with ChangeNotifier {
  final List<TranscribedWord> _transcribedWords = [];
  bool _isInitialized = false;

  TranscribedWord? twToCopy;
  
  List<TranscribedWord> get transcribedWords => _transcribedWords;
  bool get isInitialized => _isInitialized;

  void addWord(TranscribedWord tw) {
    if (_transcribedWords.isNotEmpty && _transcribedWords.last.endTime != tw.startTime) {
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
        tw.order = tw.order - 1;
      }
    }
    notifyListeners();
  }

  void pasteBefore(TranscribedWord twToIndex) {
    if (twToCopy == null) return;

    int duration = twToCopy!.endTime - twToCopy!.startTime;

    TranscribedWord newTw = TranscribedWord.copy(
        text: twToCopy!.text,
        startTime: twToCopy!.startTime,
        endTime: twToCopy!.endTime,
        currentStartTime: twToIndex.currentStartTime,
        currentEndTime: twToIndex.currentStartTime + duration,
        order: twToIndex.order,
        projectDirectory: twToCopy!.projectDirectory);

    for (TranscribedWord tw in _transcribedWords) {
      if (tw.currentStartTime >= twToIndex.currentStartTime) {
        tw.currentStartTime += duration;
        tw.currentEndTime += duration;
        tw.order = tw.order + 1;
      }
    }

    _transcribedWords.insert(_transcribedWords.indexOf(twToIndex), newTw);
    notifyListeners();
  }

  void pasteAfter(TranscribedWord twToIndex) {
    if (twToCopy == null) return;

    int duration = twToCopy!.endTime - twToCopy!.startTime;
    TranscribedWord newTw = TranscribedWord.copy(
        text: twToCopy!.text,
        startTime: twToCopy!.startTime,
        endTime: twToCopy!.endTime,
        currentStartTime: twToIndex.currentEndTime,
        currentEndTime: twToIndex.currentEndTime + duration,
        order: twToIndex.order + 1,
        projectDirectory: twToCopy!.projectDirectory);

    for (TranscribedWord tw in _transcribedWords) {
      if (tw.currentStartTime > twToIndex.currentStartTime) {
        tw.currentStartTime += duration;
        tw.currentEndTime += duration;
        tw.order = tw.order + 1;
      }
    }

    _transcribedWords.insert(_transcribedWords.indexOf(twToIndex) + 1, newTw);
    notifyListeners();
  }

  void copyWord(TranscribedWord twToCopy) {
    this.twToCopy = twToCopy;
  }

  void clearList() {
    _transcribedWords.clear();
  }
  
  void markAsInitialized() {
    _isInitialized = true;
    notifyListeners();
  }
  
  String getJSON() => jsonEncode(_transcribedWords);

  void readWordsFromFile(jsonString) {
    clearList();
    List<dynamic> wordsMap = jsonDecode(jsonString);
    for (dynamic word in wordsMap) {
      _transcribedWords.add(TranscribedWord.fromJson(word));
    }
  }
}
