import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssk/models/user.dart';
import 'package:ssk/models/esm_test_log.dart';
import 'package:ssk/webview.dart';
import 'package:ssk/service/api_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ** TODO **
// 포그라운드에서 검사함수
// 시간 받아옴
// 검사함수
//     esmTestLog 불러오고 현재 시간과 비교(어차피 알람시간에 호출할거임)
// 알람 함수 (showNotification)
// 실행함수
//     알람시간 스케줄링 -> 알람시간마다 검사함수 호출 -> 반환값에 따라 알람함수 호출
// **

// 알림 관련 기능

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

// 시간 받아오는 메소드
Future<List<String>> fetchAlarmTimes(String loginId, String password) async {
  final ApiService apiService = ApiService();
  User user = await apiService.postUser(loginId, password);

  return user.alarmTimes ?? [];
}

// 검사함수
Future<bool> checkForEsmTestLog(int userId) async {
  final ApiService apiService = ApiService();

  // 사용자의 최근 esmTestLog 시간 불러옴
  EsmTestLog esmTestLog = await apiService.postEsmTestLog(userId!);

  // date와 time 속성을 사용하여 DateTime 객체를 생성
  DateTime? esmTestLogTime;
  if (esmTestLog.date != null && esmTestLog.time != null) {
    esmTestLogTime = DateTime.parse("${esmTestLog.date} ${esmTestLog.time}");
  }

  // 현재 시간 가져옴
  DateTime now = DateTime.now();

  // DateTime? esmTestLog = await apiService.postEsmTestLog(loginId, password);
  if (esmTestLogTime != null) {
    // 알람 시간과 esmTestLog 시간의 차이를 계산
    Duration diff = now.difference(esmTestLogTime);
    // 차이가 20분 초과라면 esmTestLog가 최근 20분내에 없는것으로 판단 -> 초로 바꿈
    return diff.inMinutes > 20;
  }
  // esmTestLogTime이 null이라면 최근 로그가 없는것으로 판단하고 true 반환
  return true;
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

// 알람 발생 메소드
showNotification() async {
  var iosDetails = DarwinNotificationDetails(
    presentAlert: true, // 알림
    presentBadge: true, // 뱃지(앱 아이콘 위에 숫자)
    presentSound: true, // 소리
  );
  // 알림 id, 제목, 내용
  notifications.show(
    1,
    '정서 반복 기록시간',
    '검사 할 시간입니다.',
    NotificationDetails(iOS: iosDetails),
  );
}

// 알람 실행 함수
Future<void> executeAlarm(String loginId, String password, int userId) async {
  List<String> alarmTimes = await fetchAlarmTimes(loginId, password);
  tz.initializeTimeZones();
  var koreaTimeZone = tz.getLocation("Asia/Seoul");

  for (String time in alarmTimes) {
    DateTime scheduledTime = DateTime.parse(time);
    tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, koreaTimeZone);
    DateTime now = DateTime.now();
    tz.TZDateTime tzNow = tz.TZDateTime.from(now, koreaTimeZone);

    // 계산된 delay가 음수이면 이미 지난 시간이므로 타이머 설정을 건너뛴다.
    if (tzScheduledTime.isAfter(tzNow)) {
      Duration delay = tzScheduledTime.difference(tzNow);
      // Timer를 설정하여 delay 후에 로직을 실행
      Timer(delay, () async {
        // 여기서 검사 함수 호출
        bool shouldTrigger =
            await checkForEsmTestLog(userId); // Example user ID

        if (shouldTrigger) {
          // 조건에 따라 알람 발생
          await showNotification();
        }
      });
    }
  }
}
