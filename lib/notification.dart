import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ssk/models/user.dart';
import 'package:ssk/models/esm_test_log.dart';
import 'package:ssk/webview.dart';
import 'package:ssk/service/api_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
    '정서 반복 기록시간',
    '검사 할 시간입니다.',
    NotificationDetails(iOS: iosDetails),
  );
}

// 시간 기능 추가된 알림
showNotifications2(String loginId, String password) async {
  // API 인스턴스 생성
  final ApiService apiService = ApiService();

  // API를 통해 알람 시간 가져오기
  User user = await apiService.postUser(loginId, password);
  List<String>? alarmTimes = user.alarmTimes;
  print("debug : $alarmTimes");
  if (alarmTimes != null) {
    // 시간 관련 함수 사용 시 있어야 하는 코드
    tz.initializeTimeZones();

    var iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    for (String alarmTime in alarmTimes) {
      // API 응답에서 시간 추출
      List<String> timeParts = alarmTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      int second = int.parse(timeParts[2]);

      var notificationTime = makeDate(hour, minute, second);
      // checkForEsmTestLog 호출해서 검사 -> 그 뒤에 bool hasRecentEsmTestLog =
      //    await checkForEsmTestLog(user.id!, scheduledDate); 호출해서 true면 알림 주고 , 그렇지 않으면 알림 주지 않는거
      // 특정 시간 알림
      notifications.zonedSchedule(
        alarmTimes.indexOf(alarmTime) + 1, // 알람 고유 id
        '정서 반복 기록 검사',
        '검사 할 시간입니다.',
        notificationTime,
        NotificationDetails(iOS: iosDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("Notification scheduled for $hour:$minute:$second");
    }
  }
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

// 특정 시간에 알람을 스케줄링 하기 전에 esmTestLog가 있는지 확인하는 함수
Future<bool> checkForEsmTestLog(int userId, DateTime alarmTime) async {
  final ApiService apiService = ApiService();

  // 사용자의 최근 esmTestLog 시간 불러옴
  EsmTestLog esmTestLog = await apiService.postEsmTestLog(userId!);
  // date와 time 속성을 사용하여 DateTime 객체를 생성
  DateTime? esmTestLogTime;
  if (esmTestLog.date != null && esmTestLog.time != null) {
    esmTestLogTime = DateTime.parse("${esmTestLog.date} ${esmTestLog.time}");
  }
  // DateTime? esmTestLog = await apiService.postEsmTestLog(loginId, password);
  if (esmTestLogTime != null) {
    // 알람 시간과 esmTestLog 시간의 차이를 계산
    Duration diff = alarmTime.difference(esmTestLogTime);

    // 차이가 20분 초과라면 esmTestLog가 최근 20분내에 없는것으로 판단
    return diff.inMinutes > 20;
  }
  // esmTestLogTime이 null이라면 최근 로그가 없는것으로 판단하고 true 반환
  return true;
}

// 시간 기능 추가된 알림을 수정하여 esmTestLog 확인 로직을 포함
void integratedNotification(String loginId, String password) async {
  final ApiService apiService = ApiService();
  User user = await apiService.postUser(loginId, password);
  List<String>? alarmTimes = user.alarmTimes;

  if (alarmTimes != null) {
    tz.initializeTimeZones();
    var iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    for (String alarmTime in alarmTimes) {
      List<String> timeParts = alarmTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      int second = int.parse(timeParts[2]);
      DateTime now = DateTime.now();
      var scheduledDate =
          DateTime(now.year, now.month, now.day, hour, minute, second);
      var notificationTime = tz.TZDateTime.from(scheduledDate, tz.local);

      // 알람 시간 이전 최근 20분 내에 esmTestLog가 있는지 확인
      bool hasRecentEsmTestLog =
          await checkForEsmTestLog(user.id!, scheduledDate);
      if (!hasRecentEsmTestLog) {
        var notificationTime = tz.TZDateTime.from(scheduledDate, tz.local);
        // esmTestLog가 없다면 알람 스케줄
        notifications.zonedSchedule(
          alarmTimes.indexOf(alarmTime) + 1, // 알람 고유 id
          '정서 반복 기록 검사', // 알람 제목
          '검사 할 시간입니다.', // 알람 내용
          notificationTime, // 알람 시간
          NotificationDetails(iOS: iosDetails),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}

Future<bool> shouldTriggerNotification(int userId, DateTime alarmTime) async {
  final ApiService apiService = ApiService();
  EsmTestLog esmTestLog = await apiService.postEsmTestLog(userId);

  // esmTestLog 시간 파싱
  DateTime? esmTestLogTime;
  if (esmTestLog.date != "-" && esmTestLog.time != "-") {
    esmTestLogTime = DateTime.parse("${esmTestLog.date} ${esmTestLog.time}");
  }

  if (esmTestLogTime != null) {
    // 알람 시간과 esmTestLog 시간의 차이를 계산
    Duration diff = alarmTime.difference(esmTestLogTime);

    // esmTestLog가 최근 20분 내에 존재하면 알람을 주지 않음
    if (diff.inMinutes <= 20) {
      return false;
    }
  }
  // esmTestLog가 없거나 20분 이전인 경우 알람을 줘야 함
  return true;
}

void triggerNotificationIfRequired(int userId, DateTime alarmTime) async {
  bool shouldTrigger = await shouldTriggerNotification(userId, alarmTime);
  if (shouldTrigger) {
    showNotification(); // 알림 발생 함수 호출
  }
}
