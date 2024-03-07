import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

      if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
          if let config = NSDictionary(contentsOfFile: path) {
              if let apiKey = config["APIKey"] as? String {
                  GMSServices.provideAPIKey(apiKey)
              }
          }
      }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
