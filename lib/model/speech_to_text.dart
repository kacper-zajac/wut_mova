import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pb.dart' as gcs;
import 'package:google_speech/google_speech.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mova/model/transcribed_word.dart';


class SpeechToText1 {
  late ServiceAccount _serviceAccount;
  late SpeechToText _speechToText;
  late RecognitionConfig _config;

  SpeechToText1();

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  init() async {
    String json = await loadAsset('lib/wut-mova-7c1c055a55f6.json');
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

  Future<void> getTranscript(
      List<TranscribedWord> transcribedWords, String path) async {
    final audio = File(path).readAsBytesSync().toList();
    await _speechToText.recognize(_config, audio).then((value) {
      for (gcs.WordInfo wi in value.results.first.alternatives.first.words) {
        transcribedWords.add(
          TranscribedWord(
              text: wi.word,
              startTime: wi.startTime.nanos,
              endTime: wi.endTime.nanos),
        );
      }
    });
  }

  // Future<void> _copyFileFromAssets(String name) async {
  //   // var data = await rootBundle.load('assets/$name');
  //   // final directory = await getApplicationDocumentsDirectory();
  //   // final path = directory.path + '/$name';
  //   // await File(path).writeAsBytes(
  //   //     data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  // }
  //
  // Future<Stream<List<int>>> _getAudioStream(String path) async {
  //   if (!File(path).existsSync()) {
  //     await _copyFileFromAssets(path);
  //   }
  //   return File(path).openRead();
  // }

  // Future<Stream> getStream(String path) async {
  //   return _speechToText.streamingRecognize(
  //     StreamingRecognitionConfig(config: _config, interimResults: true),
  //     await _getAudioStream(path),
  //   );
  // }
}

/*
Obsługa stream, która nie do końca działa
Stream responseStream = await stt.getStream('/data/user/0/pl.kacperzajac.mova/app_flutter/out_audio.wav');
responseStream.listen((data) {
  print('transcript started from file');
  print(data);
  setState(() {
    print(data.results.map((e) => e.alternatives.first.transcript).join('\n'));
    _transcript =
        data.results.map((e) => e.alternatives.first.transcript).join('\n');
  });
}, onDone: () {
  print(_transcript);
  setState(() {
    _recognizing = false;
  });
}, onError: (error) {
  print(error);
});
 */
