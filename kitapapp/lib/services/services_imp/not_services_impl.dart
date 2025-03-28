// Bildirim servis uygulaması
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kitapapp/services/notifications.dart';
import 'package:kitapapp/services/services_imp/repo_services_impl.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final BookRepository _bookRepository = BookRepository();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  @override
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings,
    );
  }

  @override
  Future<void> scheduleDailyNotification(int hour, int minute) async {
    final favoriteBooks = await _bookRepository.getFavoriteBooksDetails();

    final List<String> bookTitles =
        favoriteBooks.map<String>((book) => book['Title'].toString()).toList();

    String notificationBody =
        bookTitles.isEmpty ? "Henüz favori kitap eklemediniz." : bookTitles.join(', ');

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_favorites_channel',
      'Daily Favorites Channel',
      channelDescription: 'Daily notifications for favorite books',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.zonedSchedule(
      0,
      'Favori Kitaplarınız',
      notificationBody,
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
