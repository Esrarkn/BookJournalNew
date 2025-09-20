/*import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Timezone başlatma
    tz.initializeTimeZones();
    
    // Android ayarları
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS ayarları - düzeltildi
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Başlatma ayarları - iOS ayarları düzeltildi
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings, // Burada iosSettings kullanın, boş DarwinInitializationSettings değil
    );

    // Plugin'i başlat
    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Bildirime tıklandı: ${response.payload}');
      },
    );

    // İzinleri iste
    await _requestPermissions();
  }

  // Günlük alıntı bildirimi zamanla
  static Future<void> scheduleDailyQuoteNotification({
    required int id,
    required String title,
    required String body,
    int hour = 9,
    int minute = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_quote_channel',
      'Daily Quote Channel',
      channelDescription: 'Daily motivational quotes',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Anında bildirim gönder (test için)
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Instant notification channel',
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
      iOS: iosDetails,
    );

    await notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );
  }

  // Zamanlanmış bildirim (1 dakika sonra test için)
  static Future<void> showDelayedNotification({
    required int id,
    required String title,
    required String body,
    required int delayMinutes,
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));

    const androidDetails = AndroidNotificationDetails(
      'delayed_channel',
      'Delayed Notifications',
      channelDescription: 'Delayed notification channel',
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
      iOS: iosDetails,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    
    return scheduled;
  }

  // Geliştirilmiş izin isteme
  static Future<bool> _requestPermissions() async {
    bool allPermissionsGranted = true;

    // Bildirim izni
    final notificationStatus = await Permission.notification.request();
    if (!notificationStatus.isGranted) {
      print('❌ Bildirim izni verilmedi: $notificationStatus');
      allPermissionsGranted = false;
    } else {
      print('✅ Bildirim izni verildi');
    }

    // Android için ek izinler
    if (await Permission.scheduleExactAlarm.isDenied) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      if (!exactAlarmStatus.isGranted) {
        print('❌ Exact alarm izni verilmedi: $exactAlarmStatus');
        allPermissionsGranted = false;
      } else {
        print('✅ Exact alarm izni verildi');
      }
    }

    // Flutter Local Notifications plugin izinleri (Android için)
    final androidPlugin = notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print('Flutter plugin notification permission: $granted');
    }

    return allPermissionsGranted;
  }

  // Tüm zamanlanmış bildirimleri iptal et
  static Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
    print('Tüm bildirimler iptal edildi');
  }

  // Belirli ID'li bildirimi iptal et
  static Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
    print('$id ID\'li bildirim iptal edildi');
  }

  // Aktif bildirimleri listele (debug için)
  static Future<void> listScheduledNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await notificationsPlugin.pendingNotificationRequests();
    
    print('Bekleyen bildirimler: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      print('ID: ${notification.id}, Başlık: ${notification.title}, Gövde: ${notification.body}');
    }
  }
  
}*/