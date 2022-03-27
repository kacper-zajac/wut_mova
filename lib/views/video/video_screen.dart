import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:mova/provider/video_timer.dart';
import 'package:mova/views/widgets/transcript_widget.dart';
import 'package:mova/views/widgets/video_widget.dart';
import 'package:provider/provider.dart';

class VideoScreen extends StatelessWidget {
  static const id = 'videoscreen';

  @override
  Widget build(BuildContext context) {
    final _projectName = ModalRoute.of(context)!.settings.arguments as String;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VideoPath>(
          create: (context) => VideoPath(),
        ),
        ChangeNotifierProvider<TranscribedWords>(
          create: (context) => TranscribedWords(),
        ),
        ChangeNotifierProvider<VideoTimer>(
          create: (context) => VideoTimer(),
        ),
      ],
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VideoWidget(_projectName),
              TranscriptWidget(_projectName),
            ],
          ),
        ),
      ),
    );
  }
}
