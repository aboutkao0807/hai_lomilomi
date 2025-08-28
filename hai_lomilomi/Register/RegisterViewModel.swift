
//註冊資料
import Foundation
import FirebaseAuth
import FirebaseFirestore

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
        guard let user = Auth.auth().currentUser else {
            onError?(RegisterError.notLoggedIn.localizedDescription); return
        }
        let nameTrim = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneTrim = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nameTrim.isEmpty else {
            onError?(RegisterError.invalid("請輸入姓名").localizedDescription); return
        }
        guard !phoneTrim.isEmpty else {
            onError?(RegisterError.invalid("請輸入電話").localizedDescription); return
        }

        onLoading?(true)
        let now = FieldValue.serverTimestamp()
        let doc = db.collection("users").document(user.uid)

        let data: [String: Any] = [
            "uid": user.uid,
            "name": nameTrim,
            "phone": phoneTrim,
            "email": user.email ?? "",
            "role": "customer",            // 先預設為一般會員
            "points": 0,
            "status": "active",
            "updatedAt": now,
            "createdAt": now
        ]

        doc.setData(data, merge: true) { [weak self] err in
            guard let self = self else { return }
            self.onLoading?(false)
            if let err = err {
                self.onError?(RegisterError.firestore(err.localizedDescription).localizedDescription)
            } else {
                self.onSuccess?()
            }
        }
    }
}
