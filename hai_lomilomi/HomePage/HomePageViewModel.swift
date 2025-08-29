
import Foundation
import FirebaseAuth
import GoogleSignIn



final class HomePageViewModel {
    // Output
    var onSignedOut: (() -> Void)?
    var onError: ((String) -> Void)?

    func logoutTapped() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            onSignedOut?()
        } catch {
            onError?("登出失敗：\(error.localizedDescription)")
        }
    }
}
