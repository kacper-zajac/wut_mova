import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/provider/file_path.dart';
import 'package:mova/provider/transcribed_words.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

//TODO take care of Utils split them

// TODO add cloud getting and sending and deleting

class Utils {
  // Data Saving
  static void retrieveDataIfSaved(BuildContext context, String projectPath) async {
    String saveFilePath = projectPath + kSaveFileName;
    if (File(saveFilePath).existsSync()) {
      Map<String, dynamic> jsonString = await json.decode(await File(saveFilePath).readAsString());

      Provider.of<TranscribedWords>(context, listen: false)
          .readWordsFromFile(jsonString['transcribedWords']);
      Provider.of<VideoPath>(context, listen: false).setVideoPath(jsonString["videoPath"]);
    }
  }

  static bool handleUninitialized(BuildContext context, String projectPath) {
    if (Provider.of<VideoPath>(context, listen: false).videoPath == null) {
      if (Directory(projectPath).existsSync() && !File(projectPath + kSaveFileName).existsSync()) {
        Directory(projectPath).deleteSync(recursive: true);
        return true;
      }
    }
    return false;
  }

  static Future<String?> getSaveFileJsonString(BuildContext context, String projectPath) async {
    String transcribedWordJson = Provider.of<TranscribedWords>(context, listen: false).getJSON();
    String? videoPath = Provider.of<VideoPath>(context, listen: false).videoPath;

    Map<String, dynamic> jsonMap = {
      'videoPath': videoPath ?? '',
      'transcribedWords': transcribedWordJson,
    };

    String toWrite = json.encode(jsonMap);
    if (File(projectPath + kSaveFileName).existsSync() &&
        await File(projectPath + kSaveFileName).readAsString() == toWrite) {
      return null;
    } else {
      return toWrite;
    }
  }

  static Future<bool> saveProgress(
      BuildContext context, String projectPath, String jsonToWrite) async {
    try {
      String saveFilePath = projectPath + kSaveFileName;
      if (File(saveFilePath).existsSync()) File(saveFilePath).deleteSync();

      File(saveFilePath).writeAsString(jsonToWrite);
    } catch (e) {
      return await showErrorDialog(context, e.toString()) ?? false;
    }
    return true;
  }

  // unused now
  static Future<bool> saveProgressFromScratch(BuildContext context, String projectPath) async {
    try {
      String saveFilePath = projectPath + kSaveFileName;
      if (File(saveFilePath).existsSync()) File(saveFilePath).deleteSync();

      String transcribedWordJson = Provider.of<TranscribedWords>(context, listen: false).getJSON();
      String? videoPath = Provider.of<VideoPath>(context, listen: false).videoPath;

      Map<String, dynamic> jsonMap = {
        'videoPath': videoPath ?? '',
        'transcribedWords': transcribedWordJson,
      };

      File(saveFilePath).writeAsString(json.encode(jsonMap));
    } catch (e) {
      return await showErrorDialog(context, e.toString()) ?? false;
    }
    return true;
  }

  // show dialogs

  static Future<bool?> showAlertDialog(BuildContext context, String text) async =>
      await showCustomDialog(
        context: context,
        bodyText: text,
        title: 'Alert!',
        optionTrue: 'Proceed',
        optionFalse: 'Cancel',
      );

  static Future<bool?> showErrorDialog(BuildContext context, String text) async =>
      await showCustomDialog(
        context: context,
        bodyText: text,
        title: 'Error!',
        optionTrue: 'Ignore',
        optionFalse: 'Take me back',
      );

  static Future<bool?> showCustomDialog({
    required BuildContext context,
    required String bodyText,
    required String title,
    required String optionTrue,
    required String optionFalse,
  }) async =>
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(bodyText),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(optionTrue),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(optionFalse),
              ),
            ],
          );
        },
      );

  static Future<bool?> showDialogSelfExpire(
          {required BuildContext context, required String title}) async =>
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Text(title),
              ),
            ),
          );
        },
      );

  static Future<bool?> showDialogDeleteConfirmation(BuildContext context) async => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Confirmation"),
            content: const Text("Are you sure you want to delete this project?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );

  static Future<String?> showDialogGetTitle(context, controller, projectTitles) =>
      showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Project\'s name'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter the name'),
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool error = false;
                for (String t in projectTitles) {
                  if (t == controller.text) {
                    error = true;
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: const Text('The name is already in use!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Re-try'),
                          ),
                        ],
                      ),
                    );
                    break;
                  }
                }
                if (!error) {
                  Navigator.pop(context, controller.text.replaceAll(' ', '_'));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

  static Future<bool?> showDialogWorkScreen(outerContext, projectPath) async {
    String? jsonToSave = await getSaveFileJsonString(outerContext, projectPath);
    if (jsonToSave == null) return Future<bool>.value(true);
    return showDialog<bool>(
      context: outerContext,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to leave?'),
        content: const Text(
            'Everything you\'ve been working on for the last xx minutes will be lost forever!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              if (await Utils.saveProgress(context, projectPath, jsonToSave)) {
                Navigator.pop(context, true);
              } else {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save before leaving'),
          ),
        ],
      ),
    );
  }

  // random

  static Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  static Center centeredText({required String text, required TextStyle style}) {
    return Center(
      child: Text(
        text,
        style: style,
      ),
    );
  }

  static TextButton menuButton(String buttonText, IconData iconData, Function() onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.lightBlueAccent,
            child: Icon(
              iconData,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              buttonText,
              style: kBoxBottomTextStyle,
            ),
          )
        ],
      ),
    );
  }
}
