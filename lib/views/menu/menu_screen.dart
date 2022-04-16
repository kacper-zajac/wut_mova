import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mova/constants.dart';
import 'package:mova/views/menu/main_screen.dart';
import 'package:mova/views/menu/recent_projects.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:path_provider/path_provider.dart';

class MenuScreen extends StatelessWidget {
  Directory? _appDir;
  static const id = 'menuscreen';
  final TextEditingController _controller = TextEditingController();

  Future<void> getAppDirectory() async {
    _appDir = await getApplicationDocumentsDirectory();
  }

  final List<String> _projectTitles = [];

  Future<void> newProject(BuildContext context) async {
    if (_appDir == null) await getAppDirectory();
    String? title = await Utils.showDialogGetTitle(context, _controller, _projectTitles);

    _controller.clear();

    if (title == null || title.isEmpty) {
      return;
    }

    String projDirectory = _appDir!.path + '/' + title;
    Directory(projDirectory).createSync();
    String dateNow = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    var jsonString = {
      "projName": title,
      "projPath": projDirectory,
      "createDate": dateNow,
      "lastModified": dateNow
    };

    File(projDirectory + '/config').writeAsString(jsonEncode(jsonString));

    Navigator.pushNamed(context, MainScreen.id, arguments: projDirectory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ReusableTile(
                    child: Column(
                      children: [
                        const Text(
                          'Create new',
                          style: kBoxTextStyle,
                        ),
                        SizedBox(height: 40.0),
                        Container(
                            height: 150.0,
                            child: Image.asset('lib/assets/pictures/logo_customwhite.png')),
                        SizedBox(height: 40.0),
                        ReusableTile(
                          color: kBoxColorBottom,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Utils.menuButton(
                                'Create new',
                                Icons.video_call_outlined,
                                () async => await newProject(context),
                              ),
                              Utils.menuButton(
                                'Remove existing',
                                Icons.delete_forever_outlined,
                                () => {},
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0, left: 25.0, bottom: 5.0),
                child: Text(
                  'Recent Projects',
                  style: kBoxTextStyle.copyWith(fontSize: 20.0),
                ),
              ),
              RecentProjects(projectTitles: _projectTitles),
            ],
          ),
        ),
      ),
    );
  }
}
