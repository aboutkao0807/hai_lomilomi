
//註冊資料
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

enum RegisterError: LocalizedError {
    case notLoggedIn
    case invalid(String)
    case firestore(String)

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "尚未登入，請先使用 Google 登入"
        case .invalid(let msg): return msg
        case .firestore(let msg): return "儲存失敗：\(msg)"
        }
    }
}

final class RegisterViewModel {
    // Inputs
    var name: String = ""
    var phone: String = ""

    // Outputs
    var onLoading: ((Bool)->Void)?
    var onError: ((String)->Void)?
    var onSuccess: (() -> Void)?
    var emailText: ((String)->Void)?    // 給 VC 顯示 email

    private let db = Firestore.firestore()

    /// 載入目前登入者的 email（顯示用）
    func loadEmail() {
        emailText?(Auth.auth().currentUser?.email ?? "（無 Email）")
    }

    func submit() {
        guard let user = Auth.auth().currentUser else { onError?("尚未登入"); return }
        let uid = user.uid
        onLoading?(true)
        let ref = Firestore.firestore().collection("users").document(uid)

        ref.getDocument { [weak self] snap, err in
            guard let self = self else { return }
            if let err = err { self.onLoading?(false); self.onError?("查詢失敗：\(err.localizedDescription)"); return }

            if snap?.exists == true {
                self.onLoading?(false)
                self.onError?("此帳號已完成註冊，將直接帶您回首頁")
                self.onSuccess?() // 或直接導首頁
                return
            }

            // 帳號不存在 → 建立會員
            let now = FieldValue.serverTimestamp()
            let data: [String: Any] = [
                "uid": uid,
                "email": user.email ?? "",
                "name": self.name.trimmingCharacters(in: .whitespaces),
                "phone": self.phone.trimmingCharacters(in: .whitespaces),
                "role": "customer",
                "points": 0,
                "status": "active",
                "createdAt": now,
                "updatedAt": now
            ]
            ref.setData(data, merge: false) { err in
                self.onLoading?(false)
                if let err = err { self.onError?("註冊失敗：\(err.localizedDescription)"); return }
                self.onSuccess?()
            }
        }
    }
    
    func createUserIfNotExists(
        uid: String,
        data: [String: Any],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let db  = Firestore.firestore()
        let ref = db.collection("users").document(uid)

        db.runTransaction({ (tx, errorPointer) -> Any? in
            do {
                let snap = try tx.getDocument(ref)
                if snap.exists {
                    // 已存在的話，透過 errorPointer 回傳錯誤
                    let err = NSError(
                        domain: "Register",
                        code: 409,
                        userInfo: [NSLocalizedDescriptionKey: "已註冊"]
                    )
                    errorPointer?.pointee = err
                    return nil
                }

                // 不存在的話，建立
                tx.setData(data, forDocument: ref)
                return nil
            } catch let e {
                // getDocument 失敗也要透過 errorPointer 回傳
                errorPointer?.pointee = e as NSError
                return nil
            }
        }, completion: { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        })
    }


}
