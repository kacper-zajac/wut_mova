import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
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
  final db = FirebaseStorage.instance;

  Future<List<ReusableListTile>> _getProjects(DatabaseType databaseType) {
    switch (databaseType) {
      case DatabaseType.local:
        return _getProjectsLocal();
      case DatabaseType.cloud:
        return _getProjectsCloud();
    }
  }

  Future<List<ReusableListTile>> _getProjectsCloud() async {
    if (_projects != null && _projects!.isNotEmpty) _projects!.removeRange(0, _projects!.length);
    List<String> _projectTitles = [];
    List<ReusableListTile> _projectsNewList = [];

    final storageRef = FirebaseStorage.instance.ref();
    print(storageRef);
    final listResult = await storageRef.listAll();

    final tempStorage = _appDir!.path + '/temp_cloud';

    if (Directory(tempStorage).existsSync()) Directory(tempStorage).deleteSync(recursive: true);

    Directory(tempStorage).createSync();

    for (var prefix in listResult.prefixes) {
      _projectTitles.add(prefix.fullPath);
      String projectPath = tempStorage + '/' + prefix.fullPath;
      Directory(projectPath).createSync();

      final pathReference = storageRef.child(prefix.fullPath);
      final configReference = pathReference.child('config');
      final configFile = File(projectPath + '/config');

      final thumbnailReference = pathReference.child(kThumbnailFileName);
      final thumbnailFile = File(projectPath + kThumbnailFileName);
      try {
        await configReference.writeToFile(configFile);
        try {
          await thumbnailReference.writeToFile(thumbnailFile);
        } catch(e) {}
        Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
        _projectTitles.add(config['projName']!);
        _projectsNewList.add(
          ReusableListTile(
            projectReference: pathReference,
            currentDatabaseType: DatabaseType.cloud,
            projName: config['projName']!,
            createDate: config['createDate']!,
            projPath: projectPath,
            refreshCallback: refreshListCurrentType,
          ),
        );
      } catch (e) {}
    }
    widget.callback(_projectTitles);
    return _projectsNewList;
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
            currentDatabaseType: DatabaseType.local,
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
