import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:mova/views/widgets/utils.dart';

import '../../constants.dart';
import 'work_screen.dart';

class ReusableListTile extends StatefulWidget {
  const ReusableListTile({Key? key, required configFile, required this.projPath}) : super(key: key);

  final String projPath;

  @override
  State<ReusableListTile> createState() => _ReusableListTileState();
}

class _ReusableListTileState extends State<ReusableListTile> {
  init() async {
    final data = await json.decode(await File(widget.projPath + '/config').readAsString());

    setState(() {
      title = data['projName'];
      date = data['createDate'];
      _initialized = true;
    });
  }

  bool _error = false;
  bool _initialized = false;
  late String title;
  late String date;

  void openProject(BuildContext context) {
    if (Directory(widget.projPath).existsSync()) {
      Navigator.pushNamed(context, WorkScreen.id, arguments: widget.projPath);
    } else {
      setState(() {
        _error = true;
      });
    }
  }

  void deleteProject(BuildContext context) {
    if (Directory(widget.projPath).existsSync()) {
      Navigator.pushNamed(context, WorkScreen.id, arguments: widget.projPath);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return errorBehaviour();
    } else if (_initialized) {
      return expectedBehaviour(context);
    } else {
      return const Center(child: CircularProgressIndicator());
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
            } else if (Directory(widget.projPath).existsSync()) {
              Directory(widget.projPath).deleteSync(recursive: true);
            } else {
              setState(() {
                _error = true;
              });
            }
          } else {
            // upload
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
                  title,
                  style: kBoxBottomTextStyle,
                ),
                Text(
                  date,
                  style: kBoxBottomTextStyle,
                ),
              ],
            ),
          ),
        ),
      );
}
