import 'dart:async';
import 'dart:convert';
import 'package:ssk/models/esm_test_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

/*
 * @author Jiwon Lee
 *  API 통신 
 * postUser - 사용자의 로그인 정보
 * postUserTestLog - 사용자의 최근 정서 반복 기록 시간 확인 
 */

class ApiService {
  final dio = Dio(BaseOptions(
      baseUrl: 'http://210.125.94.105:9090/SSK/',
      headers: {
        "Content-Type": "application/json;charset=UTF-8",
        "Accept": "application/json",
      },
      validateStatus: ((status) {
        return status! < 500;
      })));

  /* -- POST /user */
  Future<User> postUser(String loginIdInput, String passwordInput) async {
    // body data
    Map data = {
      'loginId': loginIdInput,
      "password": passwordInput,
    };

    // encode Map to JSON
    var body = jsonEncode(data);

    var response = await dio.post('/user', data: body);

    int? code = response.statusCode;
    String message = response.data["message"];
    Map<String, dynamic> responseData = response.data["user"];

    User user = User.fromJson(responseData);

    /* DEBUG CONSOLE 확인*/
    debugPrint("-- POST /user");
    debugPrint("code : ${code.toString()}");
    debugPrint("message : $message");
    debugPrint("userLoginId : ${user.loginId}");
    debugPrint("userPassword : ${user.password}");

    /*TODO statusCode 따른 예외 처리
     * statusCode == 200 : 통신 성공
     * statusCode != 200 : 서버 내 오류 등으로 통신 실패
    */

    /*TODO message에 따른 예외 처리 
    * message == "User not exist" : 존재하지 않는 계정
    * message == "Not Child Account" : 아동의 계정이 아님
    * message == "success" : 아동의 계정을 정상적으로 받아옴
    */

    return user;
  }

  /* -- POST /esmTestLog */
  Future<EsmTestLog> postEsmTestLog(
      int id, String currDate, String currTime) async {
    // body data
    Map data = {
      "id": id,
      "currDate": currDate,
      "currTime": currTime,
    };

    // encode Map to JSON
    var body = jsonEncode(data);

    var response = await dio.post('/esmTestLog', data: body);

    int? code = response.statusCode;
    String message = response.data["message"];
    Map<String, dynamic> responseData = response.data["esmTestLog"];

    EsmTestLog esmTestLog = EsmTestLog.fromJson(responseData);

    /* DEBUG CONSOLE 확인*/
    debugPrint("-- POST /esmTestLog");
    debugPrint("code : ${code.toString()}");
    debugPrint("message : $message");
    debugPrint(esmTestLog.date);
    debugPrint(esmTestLog.time);

    /** TODO statusCode 따른 예외 처리
     * statusCode == 200 : 통신 성공
     * statusCode != 200 : 서버 내 오류 등으로 통신 실패
    */

    /** TODO 최근 기록 시간 가져와서 화면에 띄우기
     * 통신 성공 시 message는 모두 "success"임. 
     * 최근 기록이 없을 경우 esmTestDate와 esmTestTime이 모두 "-"로 전송됨
     * 가져와서 화면에 띄워야함! 
     */
    return esmTestLog;
  }
}
