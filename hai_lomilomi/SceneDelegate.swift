//
//  SceneDelegate.swift
//  hai_lomilomi
//
//  Created by Macintosh on 2025/8/22.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let win = UIWindow(windowScene: windowScene)
        self.window = win
        
        // 檢查是否已登入
             if let user = Auth.auth().currentUser {
                 print("使用者已登入：\(user.email ?? user.uid)")
                 //進主畫面
                 win.rootViewController = UINavigationController(rootViewController: HomePageViewController())
             } else {
                 // 未登入 → 進登入頁
                 win.rootViewController = UINavigationController(rootViewController: LoginViewController())
             }
        win.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene,
                  openURLContexts URLContexts: Set<UIOpenURLContext>) {
           guard let url = URLContexts.first?.url else { return }
           GIDSignIn.sharedInstance.handle(url)
       }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

