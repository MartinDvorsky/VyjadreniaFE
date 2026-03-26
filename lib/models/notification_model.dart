// lib/models/notification_model.dart

class NotificationModel {
  final int id;
  final String znacka;
  final String nazovstavby;
  final DateTime createdAt;
  final DateTime? firstnotification;
  final DateTime? secondnotification;
  final bool done;

  NotificationModel({
    required this.id,
    required this.znacka,
    required this.nazovstavby,
    required this.createdAt,
    this.firstnotification,
    this.secondnotification,
    required this.done,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['idnotification'] as int,
      znacka: json['znacka'] as String? ?? '',
      nazovstavby: json['nazovstavby'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      firstnotification: json['firstnotification'] != null
          ? DateTime.parse(json['firstnotification'] as String)
          : null,
      secondnotification: json['secondnotification'] != null
          ? DateTime.parse(json['secondnotification'] as String)
          : null,
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idnotification': id,
      'znacka': znacka,
      'nazovstavby': nazovstavby,
      'created_at': createdAt.toIso8601String(),
      'firstnotification': firstnotification?.toIso8601String(),
      'secondnotification': secondnotification?.toIso8601String(),
      'done': done,
    };
  }

  // Helper metódy pre kontrolu stavu notifikácií
  bool get isFirstNotificationDue {
    if (firstnotification == null || done) return false;
    return DateTime.now().isAfter(firstnotification!);
  }

  bool get isSecondNotificationDue {
    if (secondnotification == null || done) return false;
    return DateTime.now().isAfter(secondnotification!);
  }

  bool get hasActiveNotifications {
    return !done && (isFirstNotificationDue || isSecondNotificationDue);
  }

  // ✅ NOVÁ METÓDA: Vráti najbližší termín, ktorý ešte neuplynul
  DateTime? get nextUpcomingNotification {
    if (done) return null;

    final now = DateTime.now();

    // Ak prvý termín neuplynul, vráť ho
    if (firstnotification != null && firstnotification!.isAfter(now)) {
      return firstnotification;
    }

    // Ak druhý termín neuplynul, vráť ho
    if (secondnotification != null && secondnotification!.isAfter(now)) {
      return secondnotification;
    }

    // Oba termíny už uplynuli alebo nie sú nastavené
    return null;
  }

  // ✅ NOVÁ METÓDA: Má aspoň jeden termín, ktorý ešte neuplynul?
  bool get hasUpcomingNotification {
    return nextUpcomingNotification != null;
  }

  int get daysUntilFirstNotification {
    if (firstnotification == null) return 0;
    return firstnotification!.difference(DateTime.now()).inDays;
  }

  int get daysUntilSecondNotification {
    if (secondnotification == null) return 0;
    return secondnotification!.difference(DateTime.now()).inDays;
  }
}