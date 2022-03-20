import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:google_speech/generated/google/protobuf/duration.pb.dart';
import 'package:mova/provider/video_timer.dart';
import 'package:provider/provider.dart';

class TranscribedWordWidget extends StatelessWidget {
  const TranscribedWordWidget(
      {required this.text, required this.startTime, required this.endTime});

  final int startTime;
  final int endTime;
  final String text;

  // ujednolicic jednostki, policzyc to wszystko podczas tworzenia widgetu

  bool isInFrame(int? micro) {
    if ((micro != null) &&
        (micro >= startTime) &&
        (micro <= endTime)
    ){
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    int? currentMicro =
        Provider.of<VideoTimer>(context, listen: true).microSeconds;
    // int? currentSec = Provider.of<VideoTimer>(context, listen: true).seconds;
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: isInFrame(currentMicro)
            ? kTranscribedTextActive
            : kTranscribedTextInactive,
      ),
    );
  }
}
