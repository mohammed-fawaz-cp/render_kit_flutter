import Flutter
import UIKit

public class RenderKitFlutterPlugin: NSObject, FlutterPlugin {
  private static var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "render_kit_flutter", binaryMessenger: registrar.messenger())
    let instance = RenderKitFlutterPlugin()
    if let channel = channel {
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
  }

  public static func emit(actionName: String, args: [String: Any]) {
    channel?.invokeMethod("emitEvent", arguments: ["name": actionName, "args": args])
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "navigateTo":
      guard let args = call.arguments as? [String: Any],
            let screenName = args["screen"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing screen name", details: nil))
        return
      }
      let state = args["state"] as? [String: Any] ?? [:]

      DispatchQueue.main.async {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
          let navigationController: UINavigationController
          if let nav = rootViewController as? UINavigationController {
            navigationController = nav
          } else {
            // Fallback: Wrap in a new UINavigationController if the app root is not one
            navigationController = UINavigationController(rootViewController: rootViewController)
            UIApplication.shared.delegate?.window??.rootViewController = navigationController
          }
          
          let routerVC = RenderKitViewController(screenName: screenName, state: state)
          navigationController.pushViewController(routerVC, animated: true)
        }
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
