import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mova/views/menu/menu_screen.dart';
import 'package:mova/views/menu/reusable_list_tile.dart';
import 'package:mova/views/widgets/utils.dart';

import '../../constants.dart';

class RecentProjects extends StatefulWidget {
  Function callback;

  RecentProjects({Key? key, required this.callback}) : super(key: key);

  @override
  State<RecentProjects> createState() => RecentProjectsState();
}

class RecentProjectsState extends State<RecentProjects> {
  Directory? _appDir;
  List<ReusableListTile>? _projects;
  late DatabaseType currentDatabaseType;

  Future<List<ReusableListTile>> _getProjects(DatabaseType databaseType) {
    switch (databaseType) {
      case DatabaseType.local:
        return _getProjectsLocal();
      case DatabaseType.cloud:
        return Future.value(
          List<ReusableListTile>.generate(
            0,
            (index) => ReusableListTile(
              projName: '',
              createDate: '',
              projPath: 'projPath',
              refreshCallback: refreshListCurrentType,
            ),
          ),
        );
    }
  }

  Future<List<ReusableListTile>> _getProjectsLocal() async {
    if (_projects != null && _projects!.isNotEmpty) _projects!.removeRange(0, _projects!.length);

    List<ReusableListTile> _projectsNewList = [];
    List<String> _projectTitles = [];
    _appDir ??= await Utils.getAppDirectory();
    final List<FileSystemEntity> entities = await _appDir!.list().toList();
    final Iterable<Directory> folders = entities.whereType<Directory>();
    for (final folder in folders) {
      File configFile = File(folder.path + '/config');
      if (configFile.existsSync()) {
        Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
        _projectTitles.add(config['projName']!);
        _projectsNewList.add(
          ReusableListTile(
            projName: config['projName']!,
            createDate: config['createDate']!,
            projPath: folder.path,
            refreshCallback: refreshListCurrentType,
          ),
        );
      }
    }
    widget.callback(_projectTitles);
    return _projectsNewList;
  }

  Future<void> refreshListCurrentType() async {
    _projects = await _getProjects(currentDatabaseType);
    setState(() {});
  }

  Future<void> refreshList(DatabaseType type) async {
    currentDatabaseType = type;
    await refreshListCurrentType();
  }

  @override
  void initState() {
    super.initState();
    currentDatabaseType = DatabaseType.local;
    refreshListCurrentType();
  }

  @override
  Widget build(BuildContext context) {
    if (_projects == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_projects!.isEmpty) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No projects to preview.',
              style: kBoxTextStyle,
            ),
            TextButton(
              onPressed: () => refreshList(currentDatabaseType),
              child: const Text(
                'refresh',
                style: kBoxTextStyle,
              ),
            )
          ],
        ),
      );
    } else {
      return Expanded(
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.lightBlueAccent,
          child: ListView(
            children: _projects!,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          onRefresh: () {
            return Future.delayed(const Duration(seconds: 1), () async {
              await refreshList(currentDatabaseType);
            });
          },
        ),
      );
    }
  }
}
