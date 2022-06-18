import 'package:flutter/material.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:mova/provider/video_timer.dart';
import 'package:mova/views/transcript/transcript_widget.dart';
import 'package:mova/views/video/video_widget.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatelessWidget {
  static const id = 'workscreen';
  bool _isLoading = false;
  
  setLoadingStatus(bool status) {
    _isLoading = status;
  }

  @override
  Widget build(BuildContext context) {
    final _projectDirectory = ModalRoute.of(context)!.settings.arguments as String;
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
      child: Builder(builder: (context) {
        Utils.retrieveDataIfSaved(context, _projectDirectory);
        return WillPopScope(
          onWillPop: () async {
            if(_isLoading) return false;
            if (Utils.handleUninitialized(context, _projectDirectory)) return true;
            bool? exit = await Utils.showDialogWorkScreen(context, _projectDirectory);
            return exit ?? false;
          },
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  VideoWidget(_projectDirectory, setLoadingStatus),
                  TranscriptWidget(_projectDirectory),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
