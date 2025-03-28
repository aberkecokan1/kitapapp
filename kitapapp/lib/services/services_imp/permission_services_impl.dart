// İzin servis uygulaması
import 'package:kitapapp/services/permission.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService implements IPermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() {
    return _instance;
  }

  PermissionService._internal();

  @override
  Future<bool> checkNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  @override
  Future<PermissionStatus> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      return await Permission.notification.request();
    }
    return await Permission.notification.status;
  }
}
