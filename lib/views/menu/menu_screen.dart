import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/views/video/video_screen.dart';
import 'package:mova/views/widgets/reusable_list_tile.dart';
import 'package:mova/views/widgets/reusable_tile.dart';



class MenuScreen extends StatelessWidget {
  static const id = 'menuscreen';

  final _projects = [
    ReusableListTile(text: 'example one', date: '12-42-1231', icon: Icons.ac_unit),
    ReusableListTile(text: 'example two', date: '12-42-1231', icon: Icons.padding),
    ReusableListTile(text: 'example three', date: '12-42-1231', icon: Icons.access_alarm_outlined),
    ReusableListTile(text: 'example four', date: '12-42-1231', icon: Icons.access_time_sharp),
    ReusableListTile(text: 'example five', date: '12-42-1231', icon: Icons.details),
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
                        Text(
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
                                onPressed: () {
                                  Navigator.pushNamed(context, VideoScreen.id);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.lightBlueAccent,
                                      child: Icon(
                                        Icons.video_call_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
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
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.lightBlueAccent,
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
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
                padding: const EdgeInsets.only(top: 25.0, left: 25.0, bottom: 5.0),
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
}
