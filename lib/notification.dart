import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssk/webview.dart';
import 'package:ssk/service/api_service.dart';
import 'package:ssk/models/user.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notifications = FlutterLocalNotificationsPlugin();

initNotification() async {
  var iosSetting = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initializationSettings = InitializationSettings(iOS: iosSetting);

  await notifications.initialize(
    initializationSettings,
    // webview 이동 추가
    // 알림 누르면 webview.dart로 이동,
    // 함수명: onSelectNotification , initNotification()함수에서 onSelectNotification속성 추가
    // 콜백에서 페이지 이동시면 됨, context는 parameter로 넘겨올거
  );
}

showNotification() async {
  tz.initializeTimeZones();
  var iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  //var alarmTime = makeDate(12, 12, 0);
  notifications.show(1, '제목1', '내용1', NotificationDetails(iOS: iosDetails));
}

// 시간 만들어주는 함수 -> make(7,0,0)->오전 7시 알림줌
makeDate(hour, min, sec) {
  var now = makeDate(13, 3, 0); //tz.TZDateTime.now(tz.local);
  var when =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, min, sec);
  if (when.isBefore(now)) {
    print("before");
    return when.add(Duration(days: 1));
  } else {
    print("after");
    return when;
  }
}

/*
class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static init() async {
    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      iOS: iosInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> showNotification() async {
    const NotificationDetails notificationDetails =
        NotificationDetails(iOS: DarwinNotificationDetails(badgeNumber: 1));
    await flutterLocalNotificationsPlugin.show(
        0, 'test title', 'test body', notificationDetails);
  }
}*/
