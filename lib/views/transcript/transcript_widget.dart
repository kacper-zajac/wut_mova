import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:mova/views/transcript/transcribed_word_widget.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:mova/views/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../model/transcribed_word.dart';
import '../../model/video_converter.dart';

class TranscriptWidget extends StatefulWidget {
  final String projectDirectory;

  TranscriptWidget(this.projectDirectory);

  @override
  State<TranscriptWidget> createState() => _TranscriptWidgetState();

  static _TranscriptWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<_TranscriptWidgetState>();
}

class _TranscriptWidgetState extends State<TranscriptWidget> {
  late List<TranscribedWord> _transcribedWords = [];
  bool justInitialized = true;

  final RoundedLoadingButtonController _saveButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _refreshButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _exportButtonController = RoundedLoadingButtonController();

  bool _isCopyContext = false;

  set isCopyContext(bool value) => setState(() => _isCopyContext = value);

  List<TranscribedWordWidget> getTranscript() {
    List<TranscribedWordWidget> transcribedWordWidgets = [];
    setState(() {
      for (TranscribedWord tw in _transcribedWords) {
        transcribedWordWidgets.add(TranscribedWordWidget(
          transcribedWidget: tw,
          isCopyContext: _isCopyContext,
        ));
      }
    });
    return transcribedWordWidgets;
  }

  @override
  Widget build(BuildContext context) {
    _transcribedWords = Provider.of<TranscribedWords>(context, listen: true).transcribedWords;
    if (Provider.of<TranscribedWords>(context, listen: true).isInitialized) {
      justInitialized = false;
    }
    if (_transcribedWords.isNotEmpty) {
      return transcriptSection();
    } else {
      return Padding(
        padding: EdgeInsets.all(50.0),
        child: Utils.centeredText(
          text: justInitialized ? '' : 'You cannot edit a video without any words!',
          style: kBoxBottomTextStyle,
        ),
      );
    }
  }

  Column transcriptSection() => Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 10.0,
          ),
          ConstrainedBox(
            constraints: BoxConstraints.loose(Size.fromHeight(370.0)),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Wrap(
                clipBehavior: Clip.antiAlias,
                alignment: WrapAlignment.start,
                children: getTranscript(),
              ),
            ),
          ),
          Divider(color: Colors.white70),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: StyledButton(
                        durationInSeconds: 3,
                        resetAfterDuration: false,
                        controller: _refreshButtonController,
                        onPressed: () async {
                          await VideoConverter()
                              .combineVideo(widget.projectDirectory, _transcribedWords, context);
                          _refreshButtonController.success();
                          Future.delayed(Duration(seconds: 2), () => _refreshButtonController.reset());
                        },
                        child: Text(
                          'refresh',
                          style: kBoxTextStyle.copyWith(fontSize: 15.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      flex: 2,
                      child: StyledButton(
                        durationInSeconds: 4,
                        child: Text(
                          'save',
                          style: kBoxTextStyle.copyWith(fontSize: 15.0),
                        ),
                        controller: _saveButtonController,
                        resetAfterDuration: false,
                        onPressed: () async {
                          String? jsonToSave =
                              await Utils.getSaveFileJsonString(context, widget.projectDirectory);
                          if (jsonToSave == null) {
                            return Future.delayed(
                              const Duration(seconds: 1),
                              () => _saveButtonController.success(),
                            );
                          } else {
                            await Utils.saveProgress(context, widget.projectDirectory, jsonToSave);
                            _saveButtonController.success();
                            Future.delayed(Duration(seconds: 2), () => _saveButtonController.reset());
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      flex: 2,
                      child: StyledButton(
                        durationInSeconds: 3,
                        controller: _exportButtonController,
                        resetAfterDuration: false,
                        onPressed: () async {
                          await VideoConverter().exportVideo(_exportButtonController,
                              widget.projectDirectory, _transcribedWords, context);
                          // _exportButtonController.success();
                          Future.delayed(Duration(seconds: 2), () => _exportButtonController.reset());
                        },
                        child: Text(
                          'export',
                          style: kBoxTextStyle.copyWith(fontSize: 15.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
}
