import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // MINTA IZIN NOTIFIKASI KE HP BUNDA
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'posyandu_channel',
          'Pengingat Posyandu',
          channelDescription: 'Notifikasi untuk jadwal Posyandu si kecil',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher', 
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // --- FUNGSI BARU: TES NOTIFIKASI INSTAN ---
  static Future<void> tampilkanNotifikasiInstan() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'tes_channel', 
      'Tes Notifikasi',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
        
    await flutterLocalNotificationsPlugin.show(
      99, // ID bebas
      'Horeee! 🎉',
      'Ini adalah tes. Sistem notifikasi di HP Bunda sudah jalan nih!',
      platformDetails,
    );
  }
}