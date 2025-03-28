import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kitapapp/models/api_model.dart';
import 'package:kitapapp/models/reducers.dart';
import 'package:kitapapp/models/redux_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kitapapp/screens/splash_screen.dart';
import 'package:redux/redux.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
bool isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
final store = Store<ReduxModel>(reducer,
    initialState:
        ReduxModel(apiModel: ApiModel(favorite: [], index: 0, theme: isDarkMode, language: 'tr')));
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  tz.initializeTimeZones();

  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  runApp(StoreProvider<ReduxModel>(
    store: store,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SplashScreen(isDarkMode: isDarkMode),
      ),
    ),
  ));
}
