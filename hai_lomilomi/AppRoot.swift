

import UIKit

enum AppRoot { case login, home }

enum AppRouter {
    static func setRoot(_ root: AppRoot, from anyView: UIView?) {
        let vc: UIViewController = {
            switch root {
            case .login: return UINavigationController(rootViewController: LoginViewController())
            case .home:  return UINavigationController(rootViewController: HomePageViewController())
            }
        }()

        let window = anyView?.window
        ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        guard let win = window else { return }
        win.rootViewController = vc
        UIView.transition(with: win, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
        win.makeKeyAndVisible()
    }
}
