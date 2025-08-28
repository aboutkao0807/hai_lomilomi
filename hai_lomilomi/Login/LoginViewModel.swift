import Foundation
import FirebaseAuth
import UIKit

final class LoginViewModel {
    var onLoading: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onLoginSuccess: ((User) -> Void)?
    var onRequireRegistration: ((User) -> Void)? // 第一次用此 Gmail 登入時
    var onProceedToRegister: (() -> Void)?   // 通知 VC 進註冊頁

    private let auth: AuthService
    init(auth: AuthService = AuthService()) { self.auth = auth }
    
    /// 使用者點「我要註冊」
    func startRegistration(presenting: UIViewController) {
        
        if Auth.auth().currentUser != nil {
                   onProceedToRegister?()
                   return
               }
        
//        if let _ = Auth.auth().currentUser {
//            // 已經登入過
//            onProceedToRegister?()
//            return
//        }
        // 尚未登入->先走 Google
               onLoading?(true)
               auth.signInGoogle(presenting: presenting) { [weak self] result in
                   guard let self = self else { return }
                   self.onLoading?(false)
                   switch result {
                   case .success:
                       // 不在這裡建 users 檔，交給 RegisterVC 填完再建
                       self.onProceedToRegister?()
                   case .failure(let err):
                       self.onError?(err.localizedDescription)
                   }
               }
           }
    
    
    

    func googleTapped(presenting: UIViewController) {
        onLoading?(true)
        auth.signInGoogle(presenting: presenting) { [weak self] result in
            guard let self = self else { return }
            self.onLoading?(false)
            switch result {
            case .success(let (user, isNew)):
                if isNew {
                    // 第一次 Google 登入要走註冊補資料
                    try? Auth.auth().signOut()
                    self.onError?("此 Gmail 尚未註冊，請先完成註冊流程")
                } else {
                    self.onLoginSuccess?(user)
                }
            case .failure(let err):
                self.onError?(err.localizedDescription)
            }
        }
    }
    
    
}
