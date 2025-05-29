import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton instance of the notifications plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initializes the notification plugin with Android settings
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon for notifications
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Shows a notification with the given title and body
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'recipe_channel', // Channel ID
          'Recipe Notifications', // Channel name
          importance: Importance.max, // High importance for heads-up notifications
          priority: Priority.high, // High priority
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(0, title, body, platformChannelSpecifics); // Show the notification
  }
}
