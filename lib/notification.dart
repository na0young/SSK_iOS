import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssk/webview.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notifications = FlutterLocalNotificationsPlugin();

// 1. 앱 로드시 실행할 기본 설정
initNotification(context) async {
  // iOS에서 앱 로드시 유저에게 권한요청
  var iosSetting = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  var initializationSettings = InitializationSettings(
    iOS: iosSetting,
  );
  await notifications.initialize(
    initializationSettings,
    // 알림 누르면 함수 실행
  );
}

// 2. 아래 함수 원하는 곳에서 실행하면 알림 뜸
showNotification() async {
  var iosDetails = DarwinNotificationDetails(
    presentAlert: true, // 알림
    presentBadge: true, // 뱃지(앱 아이콘 위에 숫자)
    presentSound: true, // 소리
  );
  // 알림 id, 제목, 내용
  notifications.show(
    1,
    '정서반복기록시간',
    '검사 할 시간입니다.',
    NotificationDetails(iOS: iosDetails),
  );
}

// 시간 기능 추가된 알림
showNotifications2() async {
  // 시간 관련 함수 사용 시 있어야 하는 코드
  tz.initializeTimeZones();

  var iosDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  // 특정 시간 알림
  notifications.zonedSchedule(
    2,
    '정서반복기록검사',
    '검사 할 시간입니다.',
    makeDate(21, 27, 00),
    NotificationDetails(iOS: iosDetails),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
  print("Notification scheduled for 21:27:00");
}

makeDate(hour, min, sec) {
  var now = tz.TZDateTime.now(tz.local);
  var koreaTimeZone = tz.getLocation("Asia/Seoul");
  var koreaNow = tz.TZDateTime.now(koreaTimeZone);

  var when = tz.TZDateTime(
      koreaTimeZone, now.year, now.month, now.day, hour, min, sec);
  if (when.isBefore(koreaNow)) {
    return when.add(Duration(days: 1));
  } else {
    return when;
  }
}
