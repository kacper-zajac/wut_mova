import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/provider/application_state.dart';
import 'package:mova/views/auth/authentication.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import 'menu_screen.dart';
import 'work_screen.dart';

class ReusableListTile extends StatefulWidget {
  const ReusableListTile({
    Key? key,
    required this.projName,
    required this.createDate,
    required this.projPath,
    required this.refreshCallback,
    required this.currentDatabaseType,
    this.projectReference,
  }) : super(key: key);

  final Function refreshCallback;
  final String projPath;
  final String projName;
  final String createDate;
  final DatabaseType currentDatabaseType;
  final Reference? projectReference;

  @override
  State<ReusableListTile> createState() => _ReusableListTileState();
}

class _ReusableListTileState extends State<ReusableListTile> {
  bool _error = false;

  void openProject(BuildContext context) {
    if (Directory(widget.projPath).existsSync()) {
      Navigator.pushNamed(context, WorkScreen.id, arguments: widget.projPath);
    } else {
      setState(() {
        _error = true;
      });
    }
  }

  void deleteProject() async {
    if (widget.currentDatabaseType == DatabaseType.local) {
      if (Directory(widget.projPath).existsSync()) {
        Directory(widget.projPath).deleteSync(recursive: true);
        await widget.refreshCallback();
      } else {
        setState(() {
          _error = true;
        });
      }
    } else if (widget.currentDatabaseType == DatabaseType.cloud) {
      final listResult = await widget.projectReference!.listAll();

      for (var item in listResult.items) {
        final fileReference = widget.projectReference!.child(item.name);
        await fileReference.delete();
      }
      await widget.refreshCallback();
    }
  }

  void uploadProject() async {
    if (Directory(widget.projPath).existsSync()) {
      try {
        final storageRef = FirebaseStorage.instance.ref();
        final folderRef = storageRef.child(widget.projName);

        // TODO jedna metoda zamiast powielania kodu

        final thumbnailRef = folderRef.child(kThumbnailFileName);
        File thumbnail = File(widget.projPath + kThumbnailFileName);
        if (thumbnail.existsSync()) {
          await thumbnailRef.putFile(thumbnail);
          print('thumbnail uploaded');
        }

        final saveFileRef = folderRef.child(kSaveFileName);
        File saveFile = File(widget.projPath + kSaveFileName);
        if (saveFile.existsSync()) {
          await saveFileRef.putFile(saveFile);
          print('savefile uploaded');


          Map<String, dynamic> jsonString = await json.decode(await saveFile.readAsString());
          String videoPath = jsonString["videoPath"];
          if (videoPath != widget.projPath + kVideoFileName) {
            String videoFileName = videoPath.substring(videoPath.lastIndexOf('/'));
            final videoFileRef = folderRef.child(videoFileName);
            File video = File(videoPath);
            if (video.existsSync()) {
              await videoFileRef.putFile(video);
              print('refreshed uploaded');
            }
          }
        }

        final videoRef = folderRef.child(kVideoFileName);
        File video = File(widget.projPath + kVideoFileName);
        if (video.existsSync()) {
          await videoRef.putFile(video);
          print('video uploaded');
        }

        final configFileRef = folderRef.child('/config');
        File configFile = File(widget.projPath + '/config');
        if (configFile.existsSync()) {
          await configFileRef.putFile(configFile);
          print('config uploaded');
        }

        final originalFileRef = folderRef.child(kOriginalCopyFileName);
        File originalCopy = File(widget.projPath + kOriginalCopyFileName);
        if (originalCopy.existsSync()) {
          await originalFileRef.putFile(originalCopy);
          print('original uploaded');
        }

        Directory(widget.projPath).deleteSync(recursive: true);
        Utils.simpleAlert(
            context: context,
            title: 'Success!',
            bodyText: 'The - ' + widget.projName + ' - project is now in the cloud.');
      } catch (e) {
        log(e.toString());
      }
    } else {
      setState(() {
        _error = true;
      });
    }
  }

  void downloadProject() async {
    String projPath =
        widget.projPath.substring(0, widget.projPath.lastIndexOf('temp')) + widget.projName;

    if (Directory(projPath).existsSync()) {
      projPath += '_cloudCopy';
    }

    Directory(projPath).createSync();

    final listResult = await widget.projectReference!.listAll();

    for (var item in listResult.items) {
      final fileReference = widget.projectReference!.child(item.name);
      final file = File(projPath + '/' + item.name);

      await fileReference.writeToFile(file);
    }

    Directory(projPath + kWorkDirectoryName).createSync();

    Utils.simpleAlert(
        context: context,
        title: 'Success!',
        bodyText: 'The - ' + widget.projName + ' - project is now on your device.');
  }

  Icon errorIcon() {
    return const Icon(
      Icons.error_outline_outlined,
      color: Colors.white,
      size: 50.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return errorBehaviour();
    } else {
      return expectedBehaviour(context);
    }
  }

  ReusableTile errorBehaviour() => ReusableTile(
        child: Utils.centeredText(
          text: 'The directory seem to be deleted hence can\'t be opened. Please refresh the view!',
          style: kBoxBottomTextStyle,
        ),
      );

  Dismissible expectedBehaviour(BuildContext context) => Dismissible(
        key: Key(widget.projPath),
        confirmDismiss: (DismissDirection direction) async {
          // TODO: dodać confirmation na dismiss upload
          if (direction == DismissDirection.startToEnd) {
            if (Provider.of<ApplicationState>(context, listen: false).loginState ==
                ApplicationLoginState.loggedIn) {
              return true;
            } else {
              await Utils.simpleAlert(
                context: context,
                title: 'You cannot do that!',
                bodyText: 'Login first to use the cloud storage.',
              );
              return false;
            }
          }
          if (direction == DismissDirection.endToStart)
            return await Utils.showDialogDeleteConfirmation(context);
        },
        secondaryBackground: Container(
          padding: const EdgeInsetsDirectional.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 30.0,
              )
            ],
          ),
        ),
        background: Container(
          padding: const EdgeInsetsDirectional.all(15.0),
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: widget.currentDatabaseType == DatabaseType.local
                ? const [
                    Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'upload project',
                      style: kBoxTextStyle,
                    ),
                  ]
                : const [
                    Icon(
                      Icons.cloud_download_rounded,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'download project',
                      style: kBoxTextStyle,
                    ),
                  ],
          ),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            if (_error) {
              return;
            } else {
              deleteProject();
            }
          } else if (direction == DismissDirection.startToEnd) {
            if (_error) {
              return;
            } else {
              if (widget.currentDatabaseType == DatabaseType.local) {
                uploadProject();
              } else {
                downloadProject();
              }
            }
          }
        },
        child: ReusableTile(
          onPress: () => openProject(context),
          child: ListTile(
            leading: SizedBox(
              width: 50.0,
              child: File(widget.projPath + kThumbnailFileName).existsSync()
                  ? AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: FileImage(
                              File(widget.projPath + kThumbnailFileName),
                            ),
                          ),
                        ),
                      ),
                    )
                  : errorIcon(),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.projName,
                  style: kBoxBottomTextStyle,
                ),
                Text(
                  widget.createDate,
                  style: kBoxBottomTextStyle,
                ),
              ],
            ),
          ),
        ),
      );
}
