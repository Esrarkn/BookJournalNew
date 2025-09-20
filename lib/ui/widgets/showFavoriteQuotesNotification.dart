/*import 'package:book_journal/data/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Düzeltilmiş orijinal fonksiyon
Future<void> showFavoriteQuotesNotification(String userId) async {
  final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
  
  const androidDetails = AndroidNotificationDetails(
    'daily_quote_channel',
    'Daily Quote Channel',
    channelDescription: 'Daily motivational quotes',
    importance: Importance.max,
    priority: Priority.high,
  );

  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  
  const platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails, // iOS detayları eklendi
  );
  
  await NotificationService.notificationsPlugin.zonedSchedule(
    1,
    'Test Başlık 📖',
    'Test Bildirimi - 1 dakika sonra geldi!',
    scheduledTime,
    platformDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
  
  print('Bildirim zamanlandı: $scheduledTime');
}


*/