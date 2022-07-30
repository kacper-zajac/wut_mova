import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mova/constants.dart';
import 'package:mova/views/menu/logout_controller.dart';
import 'package:mova/views/menu/recent_projects.dart';
import 'package:mova/views/menu/work_screen.dart';
import 'package:mova/views/widgets/animated_logo.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:path_provider/path_provider.dart';

import 'database_controller.dart';

enum DatabaseType { cloud, local }

class MenuScreen extends StatelessWidget {
  static const id = 'menuscreen';
  Directory? _appDir;

  Future<void> getAppDirectory() async {
    _appDir = await getApplicationDocumentsDirectory();
  }

  // Cloud vs Local state management
  final GlobalKey<RecentProjectsState> _key = GlobalKey();

  void refreshProjects(DatabaseType type) {
    _key.currentState!.refreshList(type);
  }

  final TextEditingController _controller = TextEditingController();

  List<String> _projectTitles = [];

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

    Navigator.pushNamed(context, WorkScreen.id, arguments: projDirectory);
    _key.currentState!.refreshListCurrentType();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? exit = await showDialog(
          context: context,
          builder: (BuildContext innerContext) => Utils.showCustomDialog(
            context: context,
            title: 'Leave confirmation',
            bodyText: 'Are you sure you want to close the app?',
            optionTrue: 'Leave',
            optionFalse: 'Take me back',
          ),
        );
        return exit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          // title: const Hero(
          //   tag: 'logo',
          //   child: AnimatedLogo().co,
          // ),
          backgroundColor: kBackgroundColor,
          leading: DatabaseController(
            refreshProjects: refreshProjects,
          ),
          actions: [
            LogoutController(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SafeArea(
            child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ReusableTile(
                      child: Column(
                        children: [
                          const Text(
                            'Create new local project',
                            style: kBoxTextStyle,
                          ),
                          SizedBox(height: 40.0),
                          Hero(
                            tag: 'logo',
                            child: AnimatedLogo(
                              isFullLogo: true,
                            ),
                          ),
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
                                  () => log(_projectTitles.toString()),
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
                RecentProjects(
                  key: _key,
                  callback: (projectTitles) => _projectTitles = projectTitles,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
