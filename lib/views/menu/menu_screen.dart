import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/views/video/video_screen.dart';
import 'package:mova/views/widgets/reusable_list_tile.dart';
import 'package:mova/views/widgets/reusable_tile.dart';
import 'package:path_provider/path_provider.dart';

class MenuScreen extends StatelessWidget {
  static const id = 'menuscreen';
  final TextEditingController _controller = TextEditingController();

  final List<String> _projectTitles = [
    'example one',
    'example two',
    'example three',
    'example four'
  ];

  final _projects = [
    ReusableListTile(
        text: 'example one', date: '12-42-1231', icon: Icons.ac_unit),
    ReusableListTile(
        text: 'example two', date: '12-42-1231', icon: Icons.padding),
    ReusableListTile(
        text: 'example three',
        date: '12-42-1231',
        icon: Icons.access_alarm_outlined),
    ReusableListTile(
        text: 'example four',
        date: '12-42-1231',
        icon: Icons.access_time_sharp),
    ReusableListTile(
        text: 'example five', date: '12-42-1231', icon: Icons.details),
  ];

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
                              TextButton(
                                onPressed: () async {
                                  String? title = await openDialog(context);
                                  _controller.clear();
                                  if (title == null || title.isEmpty) {
                                    return;
                                  }
                                  Directory dir = await getApplicationDocumentsDirectory();
                                  Directory(dir.path + '/' + title).createSync();
                                  Navigator.pushNamed(context, VideoScreen.id,
                                      arguments: title);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    CircleAvatar(
                                      backgroundColor: Colors.lightBlueAccent,
                                      child: Icon(
                                        Icons.video_call_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        'Create new',
                                        style: kBoxBottomTextStyle,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    CircleAvatar(
                                      backgroundColor: Colors.lightBlueAccent,
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        'Edit existing',
                                        style: kBoxBottomTextStyle,
                                      ),
                                    )
                                  ],
                                ),
                              )
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
              Expanded(
                child: ListView(
                  children: _projects,
                ),
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
                if (!error) Navigator.pop(context, _controller.text.replaceAll(' ', '_'));
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
}
