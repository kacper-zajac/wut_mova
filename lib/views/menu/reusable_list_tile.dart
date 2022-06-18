import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:mova/views/widgets/utils.dart';

import '../../constants.dart';
import 'work_screen.dart';

class ReusableListTile extends StatefulWidget {
  const ReusableListTile({
    Key? key,
    required this.projName,
    required this.createDate,
    required this.projPath,
    required this.refreshCallback,
  }) : super(key: key);

  final Function refreshCallback;
  final String projPath;
  final String projName;
  final String createDate;

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
    if (Directory(widget.projPath).existsSync()) {
      Directory(widget.projPath).deleteSync(recursive: true);
      await widget.refreshCallback();
    } else {
      setState(() {
        _error = true;
      });
    }
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
          if (direction == DismissDirection.startToEnd) return false;
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
            children: const [
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
          } else {
            // TODO: upload to cloud functionality
            return;
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
