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
        return const Icon(
          Icons.cloud_rounded,
          color: Colors.white,
        );
      case DatabaseType.local:
        return const Icon(
          Icons.cloud_off_rounded,
          color: Colors.white,
        );
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
      Utils.simpleAlert(
        bodyText: 'Login first to use the cloud storage.',
        title: 'You cannot do that!',
        context: context,
      );
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
