import 'package:flutter/material.dart';
import 'package:ssk/notification.dart';
import 'package:ssk/service/api_service.dart';
import 'package:ssk/models/user.dart';
import 'package:ssk/main_page.dart';
import 'package:ssk/notification.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    ),
  );
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();

  void _login() async {
    String loginId = _idController.text;
    String password = _pwController.text;

    try {
      // ApiService 인스턴스 생성
      final ApiService apiService = ApiService();

      // ApiService의 postUser 호출
      User user = await apiService.postUser(loginId, password);

      // 로그인이 성공한 경우
      if (user != null) {
        // 아이디, 비밀번호 확인 및 메인 페이지로 이동

        if (loginId == user.loginId && password == user.password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // 로그인 성공시 main페이지로 user 객체 전달
              builder: (context) => mainPage(user: user),
            ),
          );
        } else {
          // 로그인 실패 시 (Snackbar통해서 사용자에게 피드백 표시)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('로그인 실패. 아이디와 비밀번호를 확인하세요.'),
              ),
            );
          }
        }
      } else {
        // API 통신 실패 시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인 중 오류가 발생했습니다. 다시 시도하세요.'),
            ),
          );
        }
      }
    } catch (e) {
      // 다른 오류 처리
      print('로그인 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다. 다시 시도하세요.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 알림 초기화
    initNotification(context);
    //showNotifications2();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                ),
                Container(
                  margin: EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Text(
                        'SSK',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '정서 반복 기록 알림',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        child: TextField(
                          maxLines: 1,
                          controller: _idController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[350],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.only(top: 10),
                        child: TextField(
                          obscureText: true,
                          maxLines: 1,
                          controller: _pwController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[350],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 24),
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 111, 111),
                    ),
                    child: Text(
                      "로그인",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
