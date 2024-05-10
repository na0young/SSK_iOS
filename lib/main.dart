import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:ssk/login.dart';
import 'package:ssk/main_page.dart';
import 'package:ssk/webview.dart';
import 'package:ssk/models/user.dart';
import 'package:ssk/notification.dart';
import 'package:ssk/service/api_service.dart';
import 'package:flutter/services.dart'; // MethodChannel 위한 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  print("logged info: $isLoggedIn");
  // 사용자 정보 복원
  User? user;
  if (isLoggedIn) {
    String? loginId = prefs.getString('loginId');
    String? password = prefs.getString('password');
    int? id = prefs.getInt('id');
    String? name = prefs.getString('name');
    // 복원된 정보로 User 객체 생성
    user = User(id: id, loginId: loginId, password: password, name: name);
  }
  // MethodChannel 설정
  setupMethodChannel();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? MainPage(user: user) : LoginPage(),
    ),
  );
}

void setupMethodChannel() {
  const platform = MethodChannel('com.ssk.PSLE.dataChannel');

  // Flutter에서 Native로 알람 시간 전송
  void sendAlarmTime(DateTime time) {
    final String timeString = time.toIso8601String();
    platform.invokeMethod('scheduleAlarm', {'time': timeString});
  }

  platform.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'receiveData') {
      bool shouldNotify = call.arguments;
      if (shouldNotify) {
        showNotification();
      }
    }
  });
}
