import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage
        .request()
        .isGranted;
    return status;
  }

  static Future<bool> requestWritePermission() async {
    var status = await Permission.manageExternalStorage
        .request()
        .isGranted;
    return status;
  }
}
