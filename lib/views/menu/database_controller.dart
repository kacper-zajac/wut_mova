import 'package:flutter/material.dart';
import 'package:mova/views/auth/authentication.dart';
import 'package:mova/views/menu/menu_screen.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:provider/provider.dart';

import '../../provider/application_state.dart';

class DatabaseController extends StatefulWidget {
  DatabaseController({Key? key, required this.refreshProjects}) : super(key: key);

  Function(DatabaseType) refreshProjects;

  @override
  State<DatabaseController> createState() => _DatabaseControllerState();
}

class _DatabaseControllerState extends State<DatabaseController> {
  DatabaseType type = DatabaseType.local;

  Icon getIcon(DatabaseType type) {
    switch (type) {
      case DatabaseType.cloud:
        return const Icon(Icons.cloud_rounded);
      case DatabaseType.local:
        return const Icon(Icons.cloud_off_rounded);
    }
  }

  void handleDatabaseChange() {
    if (Provider.of<ApplicationState>(context, listen: false).loginState ==
        ApplicationLoginState.loggedIn) {
      setState(() {
        switch (type) {
          case DatabaseType.cloud:
            type = DatabaseType.local;
            break;
          case DatabaseType.local:
            type = DatabaseType.cloud;
            break;
        }
      });
      widget.refreshProjects(type);
    } else {
      Utils.showDialogSelfExpire(
        title: 'Login to use cloud storage!',
        context: context,
      );
      // TODO error on not logged in database switch attempt
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => handleDatabaseChange(),
      icon: getIcon(type),
    );
  }
}
