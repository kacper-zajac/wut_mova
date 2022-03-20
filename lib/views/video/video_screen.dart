import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/provider/video_timer.dart';
import 'package:mova/views/widgets/transcript_widget.dart';
import 'package:mova/views/widgets/video_widget.dart';
import 'package:provider/provider.dart';

class VideoScreen extends StatelessWidget {
  static const id = 'videoscreen';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FilePath>(
          create: (context) => FilePath(),
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
              VideoWidget(),
              TranscriptWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
