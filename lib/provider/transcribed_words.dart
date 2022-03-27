import 'package:flutter/material.dart';
import 'package:mova/model/transcribed_word.dart';

class TranscribedWords with ChangeNotifier {
  final List<TranscribedWord> _transcribedWords = [];

  List<TranscribedWord> get transcribedWords => _transcribedWords;

  void addWord(TranscribedWord tw){
    print(_transcribedWords);
    _transcribedWords.add(tw);
  }

  void deleteWord(TranscribedWord tw){
    _transcribedWords.remove(tw);
    notifyListeners();
  }

  void runNotifyListeners() {
    notifyListeners();
  }
}