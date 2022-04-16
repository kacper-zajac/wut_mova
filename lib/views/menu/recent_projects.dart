import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mova/views/menu/reusable_list_tile.dart';
import 'package:mova/views/widgets/utils.dart';

import '../../constants.dart';

class RecentProjects extends StatefulWidget {
  List<String> projectTitles;

  RecentProjects({Key? key, required this.projectTitles}) : super(key: key);

  @override
  State<RecentProjects> createState() => _RecentProjectsState();
}

class _RecentProjectsState extends State<RecentProjects> {
  Directory? _appDir;
  List<ReusableListTile>? _projects;

  Future<List<ReusableListTile>> _getProjects() async {
    List<ReusableListTile> _projects = [];
    List<String> _projectTitles = [];
    _appDir ??= await Utils.getAppDirectory();
    final List<FileSystemEntity> entities = await _appDir!.list().toList();
    final Iterable<Directory> folders = entities.whereType<Directory>();
    for (final folder in folders) {
      File configFile = File(folder.path + '/config');
      if (configFile.existsSync()) {
        Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
        _projectTitles.add(config['projName']!);
        _projects.add(
          ReusableListTile(
            configFile: config,
            projPath: folder.path,
          ),
        );
      }
    }
    widget.projectTitles = _projectTitles;
    return _projects;
  }

  Future<void> initScreen() async {
    _projects = await _getProjects();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (_projects == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_projects!.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No projects to preview.',
            style: kBoxTextStyle,
          ),
          TextButton(
            onPressed: () => initScreen(),
            child: const Text(
              'refresh',
              style: kBoxTextStyle,
            ),
          )
        ],
      );
    } else {
      return Expanded(
        child: RefreshIndicator(
          child: ListView(
            children: _projects!,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          onRefresh: () {
            return Future.delayed(const Duration(seconds: 1), () async {
              await initScreen();
            });
          },
        ),
      );
    }
  }
}
