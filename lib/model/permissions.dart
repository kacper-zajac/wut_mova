import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  static void requestStoragePermission() async {
    var status = await Permission.storage.request().isGranted;
  }
}
