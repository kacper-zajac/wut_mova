import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/transcribed_word.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:mova/provider/video_timer.dart';
import 'package:provider/provider.dart';

class TranscribedWordWidget extends StatelessWidget {
  TranscribedWordWidget({required this.transcribedWidget}) {
    startHighlightTime = transcribedWidget.startTime - kSpeechConstant;
    endHighlightTime = transcribedWidget.endTime + kSpeechConstant;
  }

  final TranscribedWord transcribedWidget;
  late int startHighlightTime;
  late int endHighlightTime;

  final GlobalKey containerKey = GlobalKey();
  late RenderBox box;
  late Offset position;

  @override
  Widget build(BuildContext context) {
    int? currentMicro =
        Provider.of<VideoTimer>(context, listen: true).microSeconds;
    return InkWell(
      key: containerKey,
      onTap: () {
        showMenu(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(60.0),
            ),
          ),
          color: Colors.black54,
          context: context,
          position: relRectSize,
          items: [
            menuItem(Icons.copy_all_rounded, () => {}),
            menuItem(Icons.cut_rounded, () => {}),
            menuItem(
              Icons.delete_rounded,
              () => Provider.of<TranscribedWords>(context, listen: false)
                  .deleteWord(transcribedWidget),
            ),
          ],
        );
      },
      child: Container(
        height: kWordBoxHeight,
        width: kWordBoxWidth,
        child: Center(
          child: Text(
            transcribedWidget.text,
            style: isInFrame(currentMicro)
                ? kTranscribedTextActive
                : kTranscribedTextInactive,
          ),
        ),
      ),
    );
  }

  RelativeRect get relRectSize {
    box = containerKey.currentContext?.findRenderObject() as RenderBox;
    position = box.localToGlobal(Offset.zero); //this is global position
    return RelativeRect.fromLTRB(position.dx - 21.0,
        position.dy + kWordBoxHeight, position.dx, position.dy);
  }

  bool isInFrame(int? micro) {
    if ((micro != null) &&
        (micro >= startHighlightTime) &&
        (micro <= endHighlightTime)) {
      return true;
    }
    return false;
  }
}

PopupMenuItem menuItem(IconData icon, Function() func) => PopupMenuItem(
      child: Center(
        child: TextButton(
          child: Icon(icon),
          onPressed: func,
        ),
      ),
    );
