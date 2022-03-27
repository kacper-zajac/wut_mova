import 'package:flutter/cupertino.dart';
import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pb.dart'
    as gcs;
import 'package:google_speech/google_speech.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mova/model/transcribed_word.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

class SpeechToText1 {
  late ServiceAccount _serviceAccount;
  late SpeechToText _speechToText;
  late RecognitionConfig _config;

  SpeechToText1();

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  init() async {
    String json = await loadAsset('lib/wut-mova-344119-ba7ed2dfbbb3.json');
    _serviceAccount = ServiceAccount.fromString(json);
    _speechToText = SpeechToText.viaServiceAccount(_serviceAccount);
    _config = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.video,
        enableAutomaticPunctuation: false,
        sampleRateHertz: 48000,
        audioChannelCount: 2,
        enableWordTimeOffsets: true,
        languageCode: 'en-US');
  }

  Future<void> getTranscript(BuildContext context, String audioPath, String projectName) async {
    await init();

    Directory dir = await getApplicationDocumentsDirectory();
    Directory(dir.path + '/' + projectName + '/' + kWorkDirectoryName)
        .createSync();

    final audio = File(audioPath).readAsBytesSync().toList();

    await _speechToText.recognize(_config, audio).then(
      (value) {
        int iter = 0;
        for (gcs.SpeechRecognitionResult results in value.results) {
          for (gcs.WordInfo wi in results.alternatives.first.words) {
            int startTimeSec = wi.startTime.seconds.toInt() * 1000000;
            int startTimeMicroSec =
                wi.startTime.nanos ~/ 1000 - kSpeechConstant;
            int endTimeSec = wi.endTime.seconds.toInt() * 1000000;
            int endTimeMicroSec = wi.endTime.nanos ~/ 1000 + kSpeechConstant;
            Provider.of<TranscribedWords>(context, listen: false).addWord(
              TranscribedWord(
                text: wi.word,
                startTime: startTimeSec + startTimeMicroSec,
                endTime: endTimeSec + endTimeMicroSec,
                order: iter++,
                projectName: projectName,
              ),
            );
          }
        }
        Provider.of<TranscribedWords>(context, listen: false).runNotifyListeners();
      },
    );
  }
}
