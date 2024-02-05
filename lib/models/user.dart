/*  
 * @author Jiwon Lee
 *  API 통신 응답 시 사용하는 객체 
 * User : 사용자 정보
 */

class User {
  int? id; // 사용자 식별 아이디
  String? loginId; // 사용자 로그인 아이디
  String? password; // 사용자 로그인 비밀번호
  String? name; // 사용자 이름

  User({this.id, this.loginId, this.password, this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      loginId: json['loginId'],
      password: json['password'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "loginId": loginId,
        "password": password,
        "name": name,
      };
  void logout() {
    // 로그아웃을 위한 앱내변수 삭제
    loginId = null;
    password = null;
  }
}
