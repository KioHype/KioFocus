import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> showTimerDone(String appName) async {
    await init();

    // KioHype: coloque seu arquivo de áudio em:
    // android/app/src/main/res/raw/kio_notification.mp3
    // e descomente a linha abaixo:
    //
    // const sound = RawResourceAndroidNotificationSound('kio_notification');

    const androidDetails = AndroidNotificationDetails(
      'kiofocus_timer',
      'Timer KioFocus',
      channelDescription: 'Notificação quando o timer de bloqueio termina',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      // sound: sound,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      'KioFocus — Timer concluído!',
      'Você pode abrir $appName agora.',
      details,
    );
  }

  static Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}