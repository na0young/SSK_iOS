import UIKit
import Flutter
import BackgroundTasks

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  // 애플리케이션이 시작될 때 호출되는 함수
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // 백그라운드 작업 등록
    registerBackgroundTasks()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  private func setupMethodChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }
        methodChannel = FlutterMethodChannel(name: "com.ssk.PSLE.dataChannel", binaryMessenger: controller.binaryMessenger)

        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "scheduleAlarm", let args = call.arguments as? [String: Any], let timeString = args["time"] as? String, let time = ISO8601DateFormatter().date(from: timeString) {
                self?.scheduleBackgroundTask(alarmTime: time)
                result("Alarm scheduled for \(time)")
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
  // iOS 13.0 이상에서 백그라운드 작업을 등록하는 함수
  @available(iOS 13.0, *)
  func registerBackgroundTasks() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.ssk.PSLE.esmCheck", using: nil) { task in
      // 백그라운드 작업 실행
      self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }
  }
  
  // 백그라운드 작업을 실제로 처리하는 함수
  func handleAppRefresh(task: BGAppRefreshTask) {
    // 작업 만료 핸들러
    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }

    // 검사 기록을 확인하고 필요에 따라 알림을 보내는 함수 호출
    checkTestLogAndNotify { success in
      // 작업 완료 알림
      task.setTaskCompleted(success: success)
    }
  }
  
  // 서버에서 검사 기록을 가져오는 함수
  func checkTestLogAndNotify() {
    fetchLastTestLog { lastTestDate in
        guard let lastTestDate = lastTestDate else {
            self.sendResultToFlutter(result: false)
            return
        }
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastTestDate)
        
        if timeInterval > 1200 { // 1200초 = 20분
            self.sendResultToFlutter(result: true)
        } else {
            self.sendResultToFlutter(result: false)
        }
    }
}
// 플러터로 검사 반환값 보내는 함수
func sendResultToFlutter(result: Bool) {
    if let controller = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "com.ssk.PSLE.dataChannel", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("receiveData", arguments: result)
    }
}

  // Flutter에 알림을 보내는 함수
  /*func notifyFlutterToTriggerAlert() {
    DispatchQueue.main.async {
        if let controller = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "com.ssk.PSLE.notifications", binaryMessenger: controller.binaryMessenger)
            channel.invokeMethod("triggerAlert", arguments: nil)
        }
    }
  */
}

// 서버 응답을 위한 구조체 정의
struct EsmTestLogResponse: Codable {
  var lastTestTime: Date?
}
