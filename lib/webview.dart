import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ssk/main_page.dart';
import 'package:ssk/models/user.dart';

class Record extends StatelessWidget {
  final String? userId;
  final String? userPw;
  WebViewController? controller;

  Record({Key? key, required this.userId, required this.userPw})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userId == null || userPw == null) {
      // userId 또는 userPw가 null일 때 처리
      return Scaffold(
        body: Center(
          child: Text('오류: 사용자 정보가 누락되었습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '정서 반복 기록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: WebView(
        onWebViewCreated: (WebViewController controller) {
          this.controller = controller;
        },
        initialUrl:
            'http://220.69.171.39:8080/SSK/doLogin?userid=$userId&userpw=$userPw',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
