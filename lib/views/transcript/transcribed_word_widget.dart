import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/model/transcribed_word.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:mova/provider/video_timer.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:provider/provider.dart';

class TranscribedWordWidget extends StatelessWidget {
  TranscribedWordWidget({required this.transcribedWidget}) {
    startHighlightTime = transcribedWidget.currentStartTime - kSpeechConstant;
    endHighlightTime = transcribedWidget.currentEndTime + kSpeechConstant;
  }

  final TranscribedWord transcribedWidget;
  late int startHighlightTime;
  late int endHighlightTime;

  final GlobalKey containerKey = GlobalKey();
  late RenderBox box;
  late Offset position;

  RelativeRect get relRectSize {
    box = containerKey.currentContext?.findRenderObject() as RenderBox;
    position = box.localToGlobal(Offset.zero); // global position
    return RelativeRect.fromLTRB(
        position.dx - 21.0, position.dy + kWordBoxHeight, position.dx, position.dy);
    // - 21.0 potentially to change on other devices
  }

  bool isInFrame(int? micro) {
    return ((micro != null) && (micro >= startHighlightTime) && (micro <= endHighlightTime));
  }

  PopupMenuItem menuItem(IconData icon, Function() func) => PopupMenuItem(
        child: Center(
          child: TextButton(
            child: Icon(icon),
            onPressed: func,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    int? currentMicro = Provider.of<VideoTimer>(context, listen: true).microSeconds;
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
            // TODO add other transcript actions
            menuItem(Icons.copy_all_rounded, () => {}),
            menuItem(Icons.cut_rounded, () => {}),
            menuItem(
              Icons.delete_rounded,
              () {
                Provider.of<TranscribedWords>(context, listen: false).deleteWord(transcribedWidget);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      child: SizedBox(
        height: kWordBoxHeight,
        width: kWordBoxWidth,
        child: Utils.centeredText(
          text: transcribedWidget.text,
          style: isInFrame(currentMicro) ? kTranscribedTextActive : kTranscribedTextInactive,
        ),
      ),
    );
  }
}
