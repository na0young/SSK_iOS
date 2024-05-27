import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ssk/Login.dart';
import 'package:ssk/webview.dart';
import 'package:ssk/models/user.dart';
import 'package:ssk/models/esm_test_log.dart';
import 'package:ssk/service/api_service.dart';
import 'package:ssk/notification.dart';
import 'package:flutter/services.dart';

class MainPage extends StatelessWidget {
  final User? user;

  MainPage({this.user});
  @override
  Widget build(BuildContext context) {
    // 앱 로드시 알림 초기화
    initNotification(context);
    return mainPage(user: user!);
  }
}

class mainPage extends StatefulWidget {
  final User user;
  mainPage({required this.user});
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  static const platform = MethodChannel('com.ssk.PSLE.dataChannel');
  String recentRecordTime = "";
  @override
  void initState() {
    super.initState();
    // 최근 기록 시간을 얻기 위해 API 호출
    recentCheckAndGetRecentRecordTime();
  }

  void recentCheckAndGetRecentRecordTime() async {
    if (widget.user.loginId != null && widget.user.password != null) {
      final ApiService apiService = ApiService();
      EsmTestLog esmTestLog = await apiService.postEsmTestLog(widget.user.id!);
      if (esmTestLog.date != "-" && esmTestLog.time != "-") {
        setState(() {
          recentRecordTime =
              '   최근 기록 시간 : ${esmTestLog.date} ${esmTestLog.time}';
        });
      } else {
        setState(() {
          recentRecordTime = '   최근 기록 시간 : ---';
        });
      }
    } else {
      print("사용자 인증 정보가 없어 알람 시간을 동기화할 수 없습니다.");
    }
  }

  DateTime _getAlarmDateTime(String alarmTime) {
    List<String> timeParts = alarmTime.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void synchronizeAlarmTimes() async {
    try {
      final ApiService apiService = ApiService();
      User updatedUser = await apiService.postUser(
          widget.user.loginId!, widget.user.password!);

      setState(() {
        widget.user.alarmTimes = updatedUser.alarmTimes;
      });

      if (widget.user.alarmTimes != null) {
        executeAlarm(
            widget.user.loginId!, widget.user.password!, widget.user.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알람 시간이 동기화되었습니다.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('알람 시간 동기화 중 오류가 발생했습니다. 다시 시도해주세요.'),
        ),
      );
    }
  }

  void sendAlarmTimeToNative(String alarmTime) {
    platform.invokeMethod('scheduleAlarm', {'time': alarmTime});
  }

  void _logout() {
    //user 지우기
    widget.user.logout();
    //로그인 페이지로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              '${widget.user.name}님',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 255, 111, 111),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                '로그아웃',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 100),
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 211, 211, 211),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '  정서 반복 기록',
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      recentRecordTime,
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: () {
                    // 기록하러 가기 로직 추가
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Record(
                            userId: widget.user.loginId,
                            userPw: widget.user.password),
                      ), // Replace WebViewPage with the actual class name in webview.dart
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 111, 111),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      )),
                  child: Text(
                    '기록하러 가기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: synchronizeAlarmTimes,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 147, 147, 147),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      )),
                  child: Text(
                    '알람 시간 동기화',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
