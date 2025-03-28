import 'package:permission_handler/permission_handler.dart';

abstract class IPermissionService {
  Future<bool> checkNotificationPermission();
  Future<PermissionStatus> requestNotificationPermission();
}
