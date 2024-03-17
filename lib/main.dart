import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:ssk/login.dart';
import 'package:ssk/main_page.dart';
import 'package:ssk/webview.dart';
import 'package:ssk/models/user.dart';

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
    // lastRecordTime 은 어케 가져오냐 ..
    // 복원된 정보로 User 객체 생성
    user = User(id: id, loginId: loginId, password: password, name: name);
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? MainPage(user: user) : LoginPage(),
    ),
  );
}
