import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../data/models/agenda_model.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Default to WIB

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
  }

  Future<void> scheduleAgendaReminder(AgendaModel agenda) async {
    if (kIsWeb) {
      debugPrint('Local notifications are not supported on Web using this plugin entirely.');
      return;
    }

    try {
      // Parse agenda time
      final timeParts = agenda.time.split(':');
      if (timeParts.length != 2) return;
      
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create DateTime for agenda
      final agendaDateTime = DateTime(
        agenda.date.year,
        agenda.date.month,
        agenda.date.day,
        hour,
        minute,
      );

      // Reminder is 24 hours (H-1) before the agenda
      final reminderTime = agendaDateTime.subtract(const Duration(hours: 24));

      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(DateTime.now())) return;

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'agenda_reminder_channel',
        'Agenda Reminders',
        channelDescription: 'Notifications for upcoming agendas',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails darwinPlatformChannelSpecifics =
          DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinPlatformChannelSpecifics,
        macOS: darwinPlatformChannelSpecifics,
      );

      // Use a consistent ID generated from the string
      final String idStr = agenda.id ?? agenda.title;
      final int notificationId = idStr.hashCode;
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Pengingat H-1: ${agenda.title}',
        body: 'Besok ada kegiatan di ${agenda.location} jam ${agenda.time}. Jangan lupa!',
        scheduledDate: scheduledDate,
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: agenda.id,
      );

      debugPrint('Scheduled reminder for ${agenda.title} at $scheduledDate');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }
}
