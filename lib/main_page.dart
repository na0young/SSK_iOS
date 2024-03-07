import 'package:flutter/material.dart';
import 'package:ssk/Login.dart';
import 'package:ssk/webview.dart';
import 'package:ssk/models/user.dart';
import 'package:ssk/models/esm_test_log.dart';
import 'package:ssk/service/api_service.dart';
import 'package:ssk/notification.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 앱 로드시 알림 초기화
    initNotification(context);
    showNotifications2();

    User user = User(name: "사용자");
    return MaterialApp(
      home: mainPage(user: user),
      debugShowCheckedModeBanner: false,
    );
  }
}

class mainPage extends StatefulWidget {
  final User user;
  mainPage({required this.user});
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  bool isNotificationOn = true;
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
                      '   최근 기록 시간 : 2024-01-17 13:31',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '알림 ON/OFF',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  Switch(
                    value: isNotificationOn,
                    onChanged: (value) {
                      setState(() {
                        isNotificationOn = value;
                      });
                    },
                    activeColor: Color.fromARGB(255, 255, 111, 111),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
