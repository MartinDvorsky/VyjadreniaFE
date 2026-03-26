// lib/services/notification_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;

  // ✅ Načítať všetky notifikácie
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await _supabase
          .from('notification')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Chyba pri načítaní notifikácií: $e');
      rethrow;
    }
  }

  // ✅ Načítať iba aktívne notifikácie (done = false)
  Future<List<NotificationModel>> getActiveNotifications() async {
    try {
      final response = await _supabase
          .from('notification')
          .select()
          .eq('done', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Chyba pri načítaní aktívnych notifikácií: $e');
      rethrow;
    }
  }

  // ✅ Načítať ukončené notifikácie (done = true)
  Future<List<NotificationModel>> getCompletedNotifications() async {
    try {
      final response = await _supabase
          .from('notification')
          .select()
          .eq('done', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Chyba pri načítaní ukončených notifikácií: $e');
      rethrow;
    }
  }

  // ✅ Označiť notifikáciu ako ukončenú
  Future<void> markAsComplete(int notificationId) async {
    try {
      await _supabase
          .from('notification')
          .update({'done': true})
          .eq('idnotification', notificationId);

      print('✅ Notifikácia $notificationId označená ako ukončená');
    } catch (e) {
      print('❌ Chyba pri označovaní notifikácie: $e');
      rethrow;
    }
  }

  // ✅ Vymazať notifikáciu
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _supabase
          .from('notification')
          .delete()
          .eq('idnotification', notificationId);

      print('✅ Notifikácia $notificationId vymazaná');
    } catch (e) {
      print('❌ Chyba pri mazaní notifikácie: $e');
      rethrow;
    }
  }

  // ✅ Získať počet aktívnych upozornení (s uplynulým termínom)
  Future<int> getActiveNotificationCount() async {
    try {
      final notifications = await getActiveNotifications();
      return notifications.where((n) => n.hasActiveNotifications).length;
    } catch (e) {
      print('❌ Chyba pri počítaní aktívnych notifikácií: $e');
      return 0;
    }
  }

  // ✅ Vytvoriť novú notifikáciu
  Future<NotificationModel?> createNotification({
    required String znacka,
    required String nazovstavby,
    required DateTime firstNotificationDate,
    required DateTime secondNotificationDate,
  }) async {
    try {
      print('📝 Vkladám notifikáciu do DB...');
      print('  znacka: $znacka');
      print('  nazovstavby: $nazovstavby');
      print('  firstNotification: $firstNotificationDate');
      print('  secondNotification: $secondNotificationDate');

      final response = await _supabase.from('notification').insert({
        'znacka': znacka,
        'nazovstavby': nazovstavby,
        'firstnotification': firstNotificationDate.toIso8601String(),
        'secondnotification': secondNotificationDate.toIso8601String(),
        'done': false,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      print('✅ Notifikácia úspešne vytvorená: $znacka');
      return NotificationModel.fromJson(response);
    } catch (e) {
      print('❌ KRITICKÁ CHYBA pri vytváraní notifikácie: $e');
      rethrow;
    }
  }

  // ✅ Získať notifikácie, ktoré už majú uplynúť termín
  Future<List<NotificationModel>> getOverdueNotifications() async {
    try {
      final notifications = await getActiveNotifications();
      return notifications.where((n) => n.hasActiveNotifications).toList();
    } catch (e) {
      print('❌ Chyba pri načítaní prepadnutých notifikácií: $e');
      return [];
    }
  }

  // ✅ Aktualizovať existujúcu notifikáciu
  Future<void> updateNotification({
    required int notificationId,
    String? znacka,
    String? nazovstavby,
    DateTime? firstNotification,
    DateTime? secondNotification,
    bool? done,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (znacka != null) updates['znacka'] = znacka;
      if (nazovstavby != null) updates['nazovstavby'] = nazovstavby;
      if (firstNotification != null) {
        updates['firstnotification'] = firstNotification.toIso8601String();
      }
      if (secondNotification != null) {
        updates['secondnotification'] = secondNotification.toIso8601String();
      }
      if (done != null) updates['done'] = done;

      if (updates.isEmpty) return;

      await _supabase
          .from('notification')
          .update(updates)
          .eq('idnotification', notificationId);

      print('✅ Notifikácia $notificationId aktualizovaná');
    } catch (e) {
      print('❌ Chyba pri aktualizácii notifikácie: $e');
      rethrow;
    }
  }

  // ✅ Získať notifikáciu podľa ID
  Future<NotificationModel?> getNotificationById(int notificationId) async {
    try {
      final response = await _supabase
          .from('notification')
          .select()
          .eq('idnotification', notificationId)
          .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      print('❌ Chyba pri načítaní notifikácie $notificationId: $e');
      return null;
    }
  }

  // ✅ Získať notifikácie podľa značky
  Future<List<NotificationModel>> getNotificationsByZnacka(String znacka) async {
    try {
      final response = await _supabase
          .from('notification')
          .select()
          .eq('znacka', znacka)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Chyba pri načítaní notifikácií pre značku $znacka: $e');
      return [];
    }
  }

  // ✅ Získať štatistiky notifikácií
  Future<Map<String, int>> getNotificationStats() async {
    try {
      final all = await getAllNotifications();
      final active = all.where((n) => !n.done).length;
      final completed = all.where((n) => n.done).length;
      final overdue = all.where((n) => n.hasActiveNotifications).length;

      return {
        'total': all.length,
        'active': active,
        'completed': completed,
        'overdue': overdue,
      };
    } catch (e) {
      print('❌ Chyba pri načítaní štatistík notifikácií: $e');
      return {
        'total': 0,
        'active': 0,
        'completed': 0,
        'overdue': 0,
      };
    }
  }
}

