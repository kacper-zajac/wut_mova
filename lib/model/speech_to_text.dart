import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pb.dart' as gcs;
import 'package:google_speech/google_speech.dart';
import 'package:mova/model/transcribed_word.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class SpeechToText1 {
  late ServiceAccount _serviceAccount;
  late SpeechToText _speechToText;
  late RecognitionConfig _config;
  bool isInitialized = false;

  SpeechToText1();

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  init() async {
    String json = await loadAsset('lib/wut-zajka-mova-486794de37ce.json');
    _serviceAccount = ServiceAccount.fromString(json);
    _speechToText = SpeechToText.viaServiceAccount(_serviceAccount);
    _config = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.video,
        enableAutomaticPunctuation: false,
        sampleRateHertz: 44100,
        audioChannelCount: 1,
        enableWordTimeOffsets: true,
        languageCode: 'en-US');
    isInitialized = true;
  }

  Future<void> getTranscript(
      BuildContext context, String audioPath, String projectDirectory, double duration) async {
    if (!isInitialized) await init();
    Directory(projectDirectory + kWorkDirectoryName).createSync();

    final audio = File(audioPath).readAsBytesSync().toList();
    Provider.of<TranscribedWords>(context, listen: false).clearList();
    await _speechToText.recognize(_config, audio).then(
      (value) async {
        print('---- DEBUG ----');
        print(value.toString());
        print('---- DEBUG ----');
        int iter = 0;
        int lastEndTime = 0;
        for (gcs.SpeechRecognitionResult results in value.results) {
          print('---- DEBUG ----');
          print(results.toString());
          print('---- DEBUG ----');
          for (gcs.WordInfo wi in results.alternatives.first.words) {
            int startTimeSec = wi.startTime.seconds.toInt() * 1000000;
            int startTimeMicroSec = wi.startTime.nanos ~/ 1000;
            int endTimeSec = wi.endTime.seconds.toInt() * 1000000;
            int endTimeMicroSec = wi.endTime.nanos ~/ 1000;
            print('---- DEBUG ----');
            print(wi.toString());
            print('---- DEBUG ----');

            Provider.of<TranscribedWords>(context, listen: false).addWord(
              TranscribedWord(
                text: wi.word,
                startTime: startTimeSec + startTimeMicroSec,
                endTime: endTimeSec + endTimeMicroSec,
                order: iter++,
                projectDirectory: projectDirectory,
              ),
            );
            lastEndTime = endTimeSec + endTimeMicroSec;
          }
        }
        int durationInt = (duration * 1000000).toInt();
        if(lastEndTime != 0.0 && lastEndTime < durationInt) {
          Provider.of<TranscribedWords>(context, listen: false).addWord(
            TranscribedWord(
              text: '_',
              startTime: lastEndTime,
              endTime: durationInt,
              order: iter++,
              projectDirectory: projectDirectory,
            ),
          );
        }
        Provider.of<TranscribedWords>(context, listen: false).markAsInitialized();
        String? jsonToSave = await Utils.getSaveFileJsonString(context, projectDirectory);
        if (jsonToSave != null) await Utils.saveProgress(context, projectDirectory, jsonToSave);
      },
    );
  }
}
