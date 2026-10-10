import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class SpeechPlayer {
  AudioPlayer? _instance;
  AudioPlayer get _player => _instance ??= AudioPlayer();
  Future<void> play(String id, double speed) async {
    await _player.stop();
    await _player.play(AssetSource('audio/$id.mp3'));
    await _player.setPlaybackRate(speed);
  }

  Future<void> stop() async {
    await _instance?.stop();
  }

  void dispose() {
    _instance?.dispose();
  }
}

class ReminderService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  Future<bool> setEnabled(bool enabled) async {
    if (!supported) return false;
    if (!_ready) {
      tzdata.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    }
    if (!enabled) {
      await _plugin.cancel(19);
      return true;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final allowed = android != null
        ? await android.requestNotificationsPermission()
        : await ios?.requestPermissions(alert: true, badge: false, sound: true);
    if (allowed != true) return false;
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19);
    if (!next.isAfter(now)) {
      next = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 19);
    }
    await _plugin.zonedSchedule(
      19,
      'A little Albanian, every day 🇦🇱',
      'Mirë se erdhe! Take a moment to learn a phrase and keep your streak.',
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_learning',
          'Daily learning',
          channelDescription: 'Your daily Albanian practice reminder',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }
}
