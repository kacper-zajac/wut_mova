import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mova/constants.dart';
import 'package:mova/views/video/video_screen.dart';
import 'package:mova/views/widgets/reusable_list_tile.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:path_provider/path_provider.dart';

class MenuScreen extends StatelessWidget {
  Directory? _appDir;
  static const id = 'menuscreen';
  final TextEditingController _controller = TextEditingController();

  Future<void> getAppDirectory() async {
    _appDir = await getApplicationDocumentsDirectory();
  }

  final List<String> _projectTitles = [];

  Future<List<ReusableTile>> _getProjects() async {
    List<ReusableTile> _projects = [];
    if (_appDir == null) await getAppDirectory();
    final List<FileSystemEntity> entities = await _appDir!.list().toList();
    final Iterable<Directory> folders = entities.whereType<Directory>();
    for (final folder in folders) {
      File configFile = File(folder.path + '/config');
      if (await configFile.exists()) {
        Map<String, dynamic> config =
            jsonDecode(await configFile.readAsString());
        _projectTitles.add(config['projName']!);
        _projects.add(ReusableListTile(
            text: config['projName']!,
            date: config['createDate']!,
            icon: Icons.ac_unit));
      }
    }
    return _projects;
  }

  Future<void> openProject(BuildContext context) async {
    if (_appDir == null) await getAppDirectory();
    String? title = await openDialog(context);

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

    Navigator.pushNamed(context, VideoScreen.id, arguments: projDirectory);
  }

  Future<void> newProject(BuildContext context) async {
    if (_appDir == null) await getAppDirectory();
    String? title = await openDialog(context);

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

    final data = await json.decode(await File(projDirectory + '/config').readAsString());

    if(data["projPath"] != null) {
      Navigator.pushNamed(context, VideoScreen.id, arguments: data["projPath"]);
      return;
    }

    // error popup - file corrupted
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
                            child: Image.asset(
                                'lib/assets/pictures/logo_customwhite.png')),
                        SizedBox(height: 40.0),
                        ReusableTile(
                          color: kBoxColorBottom,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              menuButton(
                                  'Create new',
                                  Icons.video_call_outlined,
                                  () async => await newProject(context)),
                              menuButton(
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
                padding:
                    const EdgeInsets.only(top: 25.0, left: 25.0, bottom: 5.0),
                child: Text(
                  'Recent Projects',
                  style: kBoxTextStyle.copyWith(fontSize: 20.0),
                ),
              ),
              FutureBuilder(
                future: _getProjects(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return Text(snapshot.error.toString());
                  } else if (snapshot.data == null ||
                      snapshot.data.length == 0) {
                    return const Expanded(
                      child: Center(
                        child: Text(
                          'Create a project first!',
                          style: kBoxTextStyle,
                        ),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView(
                        children: snapshot.data,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> openDialog(context) => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Project\'s name'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter the name'),
            controller: _controller,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool error = false;
                for (String t in _projectTitles) {
                  if (t == _controller.text) {
                    error = true;
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text('The name is already in use!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Re-try'),
                          ),
                        ],
                      ),
                    );
                    break;
                  }
                }
                if (!error) {
                  Navigator.pop(context, _controller.text.replaceAll(' ', '_'));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

  TextButton menuButton(
      String buttonText, IconData iconData, Function() onPressed) {
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
            padding: EdgeInsets.only(top: 12.0),
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
