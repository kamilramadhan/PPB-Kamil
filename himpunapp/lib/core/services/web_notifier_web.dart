// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Minta izin notifikasi browser saat app dimuat
void requestWebNotificationPermission() {
  try {
    if (html.Notification.permission == 'default') {
      html.Notification.requestPermission();
    }
  } catch (_) {}
}

/// Menampilkan browser notification (pop-up Windows/Mac/Linux)
void showWebNotification(String title, String body) {
  try {
    final permission = html.Notification.permission;
    print('Notification permission status: $permission');

    if (permission == 'granted') {
      html.Notification(title, body: body);
      print('Notification created!');
    } else if (permission != 'denied') {
      html.Notification.requestPermission().then((perm) {
        if (perm == 'granted') {
          html.Notification(title, body: body);
          print('Notification created after permission granted!');
        }
      });
    }
  } catch (e) {
    print('Failed to show web notification: $e');
  }
}
