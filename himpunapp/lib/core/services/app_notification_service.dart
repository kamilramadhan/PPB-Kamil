import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'web_notifier.dart';

/// Model untuk satu notifikasi
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'agenda', 'member', 'division', 'profile'
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.icon,
    required this.color,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Service notifikasi in-app yang bekerja di semua platform (termasuk web)
class AppNotificationService extends ChangeNotifier {
  static final AppNotificationService _instance = AppNotificationService._();
  factory AppNotificationService() => _instance;
  AppNotificationService._();

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Tambah notifikasi baru
  void notify({
    required String title,
    required String body,
    String type = 'info',
    IconData icon = Icons.notifications_rounded,
    Color color = const Color(0xFF1565C0),
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      icon: icon,
      color: color,
    );
    _notifications.insert(0, notification);

    // Batasi history sampai 50 notifikasi
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    notifyListeners();

    // Coba tampilkan browser notification di web
    if (kIsWeb) {
      showWebNotification(title, body);
    }
  }

  // ── Shortcut methods ──

  void notifyAgendaAdded(String agendaTitle) {
    notify(
      title: 'Agenda Baru Ditambahkan',
      body: '"$agendaTitle" berhasil ditambahkan ke daftar agenda.',
      type: 'agenda',
      icon: Icons.event_rounded,
      color: const Color(0xFFFF9800),
    );
  }

  void notifyAgendaUpdated(String agendaTitle) {
    notify(
      title: 'Agenda Diperbarui',
      body: '"$agendaTitle" berhasil diperbarui.',
      type: 'agenda',
      icon: Icons.event_available_rounded,
      color: const Color(0xFF4CAF50),
    );
  }

  void notifyMemberAdded(String memberName) {
    notify(
      title: 'Anggota Baru',
      body: '$memberName berhasil ditambahkan sebagai anggota.',
      type: 'member',
      icon: Icons.person_add_rounded,
      color: const Color(0xFF2196F3),
    );
  }

  void notifyMemberUpdated(String memberName) {
    notify(
      title: 'Data Anggota Diperbarui',
      body: 'Data $memberName berhasil diperbarui.',
      type: 'member',
      icon: Icons.person_rounded,
      color: const Color(0xFF2196F3),
    );
  }

  void notifyDivisionAdded(String divisionName) {
    notify(
      title: 'Divisi Baru',
      body: 'Divisi "$divisionName" berhasil ditambahkan.',
      type: 'division',
      icon: Icons.account_tree_rounded,
      color: const Color(0xFF4CAF50),
    );
  }

  void notifyDivisionUpdated(String divisionName) {
    notify(
      title: 'Divisi Diperbarui',
      body: 'Divisi "$divisionName" berhasil diperbarui.',
      type: 'division',
      icon: Icons.account_tree_rounded,
      color: const Color(0xFF4CAF50),
    );
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
