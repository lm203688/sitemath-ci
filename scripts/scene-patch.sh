#!/bin/bash
# Adopt the UIScene life cycle in the generated iOS project so the app can launch
# on iOS 26/27 simulators (UIKit now hard-asserts for apps without a scene manifest).
set -e
APP_DELEGATE="ios/SiteMath/AppDelegate.swift"
PLIST="ios/SiteMath/Info.plist"
PB=/usr/libexec/PlistBuddy

if ! grep -q "class SceneDelegate" "$APP_DELEGATE"; then
cat >> "$APP_DELEGATE" <<'SWIFT'

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let sceneWindow = UIWindow(windowScene: windowScene)
    sceneWindow.backgroundColor = UIColor.white
    if let root = appDelegate?.window?.rootViewController {
      sceneWindow.rootViewController = root
    }
    self.window = sceneWindow
    appDelegate?.window = sceneWindow
    sceneWindow.makeKeyAndVisible()
  }
}
SWIFT
fi

if ! $PB -c "Print :UIApplicationSceneManifest" "$PLIST" >/dev/null 2>&1; then
  $PB -c "Add :UIApplicationSceneManifest dict" "$PLIST"
  $PB -c "Add :UIApplicationSceneManifest:UIApplicationSupportsMultipleScenes bool false" "$PLIST"
  $PB -c "Add :UIApplicationSceneManifest:UISceneConfigurations dict" "$PLIST"
  $PB -c "Add :UIApplicationSceneManifest:UISceneConfigurations:UIWindowSceneSessionRoleApplication array" "$PLIST"
  $PB -c "Add :UIApplicationSceneManifest:UISceneConfigurations:UIWindowSceneSessionRoleApplication:0 dict" "$PLIST"
  $PB -c "Add :UIApplicationSceneManifest:UISceneConfigurations:UIWindowSceneSessionRoleApplication:0:UISceneConfigurationName string Default" "$PLIST"
  $PB -c 'Add :UIApplicationSceneManifest:UISceneConfigurations:UIWindowSceneSessionRoleApplication:0:UISceneDelegateClassName string $(PRODUCT_MODULE_NAME).SceneDelegate' "$PLIST"
fi

$PB -c "Print :UIApplicationSceneManifest" "$PLIST"
tail -30 "$APP_DELEGATE"
