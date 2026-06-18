import Flutter
import UIKit
import UserNotifications

/// iOS counterpart of the Android Kotlin notification engine. Implements the
/// `ghasaq/notifications` MethodChannel using local `UNUserNotificationCenter`
/// notifications.
///
/// iOS limits a single app to 64 pending notifications, so the 7-day horizon
/// sent by the Dart side is capped to the nearest [maxPending] future entries.
/// The full adhan cannot play in the background on iOS — adhan notifications
/// use a short bundled sound (see [adhanSound]); everything else uses the
/// default notification sound.
///
/// Android-only concepts (exact-alarm, battery optimisation, OEM autostart)
/// have no iOS equivalent: `getHealth` reports them as satisfied and the
/// "open settings" methods just open this app's iOS settings page.
public class GhasaqNotificationsPlugin: NSObject, FlutterPlugin,
  UNUserNotificationCenterDelegate
{
  /// Strong reference kept for the app lifetime: `UNUserNotificationCenter`
  /// holds its delegate weakly, so without this the plugin would be released
  /// and notification taps / foreground presentation would stop working.
  private static var shared: GhasaqNotificationsPlugin?

  private let channel: FlutterMethodChannel
  private var pendingTapPayload: String?

  /// iOS hard cap is 64 pending notifications; keep headroom for the two
  /// reserved test IDs and any race with delivery.
  private let maxPending = 60

  private static let testId = 999_999
  private static let alKahfTestId = 999_998
  private static let payloadKey = "ghasaq.notif.payload"

  init(channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "ghasaq/notifications",
      binaryMessenger: registrar.messenger()
    )
    let instance = GhasaqNotificationsPlugin(channel: channel)
    shared = instance
    registrar.addMethodCallDelegate(instance, channel: channel)
    UNUserNotificationCenter.current().delegate = instance
  }

  // MARK: - Method dispatch

  public func handle(
    _ call: FlutterMethodCall, result: @escaping FlutterResult
  ) {
    switch call.method {
    case "initialize":
      requestAuthorization()
      result(true)
    case "requestPostNotifications", "openNotificationSettings":
      // On iOS the only path to (re)grant is the system prompt or Settings.
      requestAuthorization()
      result(nil)
    case "openExactAlarmSettings", "openOemAutostart":
      openAppSettings()
      result(nil)
    case "getHealth":
      getHealth(result)
    case "sync":
      sync(call.arguments as? String, result: result)
    case "cancelAll":
      let center = UNUserNotificationCenter.current()
      center.removeAllPendingNotificationRequests()
      center.removeAllDeliveredNotifications()
      result(nil)
    case "runTest":
      schedule(
        id: Self.testId, after: 15, title: "أذان (اختبار)", body: "",
        sound: adhanSound(), payload: nil)
      result(Self.testId)
    case "runAlKahfTest":
      schedule(
        id: Self.alKahfTestId, after: 5, title: "سورة الكهف (اختبار)",
        body: "تذكير بقراءة سورة الكهف", sound: .default, payload: "al_kahf")
      result(Self.alKahfTestId)
    case "consumePendingTapPayload":
      let payload = pendingTapPayload
      pendingTapPayload = nil
      result(payload)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Authorization

  private func requestAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound, .badge]
    ) { _, _ in
      // Result is reflected later via getHealth; nothing to do here.
    }
  }

  private func getHealth(_ result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      let granted: Bool
      switch settings.authorizationStatus {
      case .authorized, .provisional:
        granted = true
      default:
        granted = false
      }
      let snapshot: [String: Any] = [
        "postNotifications": granted,
        // No iOS analogue — report satisfied so the Dart health UI is green.
        "exactAlarm": true,
        "batteryUnrestricted": true,
        "oem": [
          "manufacturer": "Apple",
          "brand": "Apple",
          "vendor": "generic",
          "isAggressive": false,
          "autostartAvailable": false,
        ],
        "scheduleLog": [],
      ]
      let json = Self.encode(snapshot)
      DispatchQueue.main.async { result(json) }
    }
  }

  // MARK: - Scheduling

  private func sync(_ jsonString: String?, result: @escaping FlutterResult) {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()

    guard
      let data = jsonString?.data(using: .utf8),
      let root = (try? JSONSerialization.jsonObject(with: data))
        as? [String: Any],
      let items = root["notifications"] as? [[String: Any]]
    else {
      result(0)
      return
    }

    let now = Date().timeIntervalSince1970
    // Keep only future entries, soonest first, within the iOS pending cap.
    let upcoming =
      items
      .compactMap { item -> (fireAt: Double, item: [String: Any])? in
        guard let millis = (item["triggerAtMillis"] as? NSNumber)?.doubleValue
        else { return nil }
        let fireAt = millis / 1000.0
        return fireAt > now ? (fireAt, item) : nil
      }
      .sorted { $0.fireAt < $1.fireAt }
      .prefix(maxPending)

    for entry in upcoming {
      scheduleEntry(entry.item, fireAt: entry.fireAt, now: now)
    }
    result(upcoming.count)
  }

  private func scheduleEntry(
    _ item: [String: Any], fireAt: Double, now: Double
  ) {
    guard let id = (item["id"] as? NSNumber)?.intValue else { return }
    let type = item["type"] as? String ?? ""
    let title = item["title"] as? String ?? ""
    let body = item["body"] as? String ?? ""
    let payload = item["payload"] as? String
    let sound: UNNotificationSound = (type == "adhan") ? adhanSound() : .default

    let interval = max(1, fireAt - now)
    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: interval, repeats: false)
    add(
      id: id, title: title, body: body, sound: sound, payload: payload,
      trigger: trigger)
  }

  private func schedule(
    id: Int, after seconds: TimeInterval, title: String, body: String,
    sound: UNNotificationSound, payload: String?
  ) {
    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: seconds, repeats: false)
    add(
      id: id, title: title, body: body, sound: sound, payload: payload,
      trigger: trigger)
  }

  private func add(
    id: Int, title: String, body: String, sound: UNNotificationSound,
    payload: String?, trigger: UNNotificationTrigger
  ) {
    let content = UNMutableNotificationContent()
    content.title = title
    if !body.isEmpty { content.body = body }
    content.sound = sound
    if let payload = payload, !payload.isEmpty {
      content.userInfo = [Self.payloadKey: payload]
    }
    let request = UNNotificationRequest(
      identifier: String(id), content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }

  /// Phase 1: default sound. Phase 2 swaps in a short (<=30s) bundled adhan
  /// clip via `UNNotificationSound(named:)`.
  private func adhanSound() -> UNNotificationSound { .default }

  // MARK: - Foreground presentation & taps

  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let payload =
      response.notification.request.content.userInfo[Self.payloadKey]
      as? String
    if let payload = payload, !payload.isEmpty {
      if UIApplication.shared.applicationState == .active {
        channel.invokeMethod("onTap", arguments: payload)
      } else {
        // Cold start: buffer until Dart pulls it via consumePendingTapPayload.
        pendingTapPayload = payload
      }
    }
    completionHandler()
  }

  // MARK: - Helpers

  private func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      return
    }
    DispatchQueue.main.async {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  private static func encode(_ object: [String: Any]) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object)
    else { return nil }
    return String(data: data, encoding: .utf8)
  }
}
