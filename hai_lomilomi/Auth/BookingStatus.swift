

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum BookingStatus: String {
    case draft            // 本地暫存，尚未送出
    case pendingPayment   // 已送出預約，等待付款
    case paid             // 已付款，但尚未確認（可選）
    case confirmed        // 預約成立（付款確認）
    case canceled         // 使用者或業主取消
    case expired          // 未付款逾時失效
    case completed        // 已到店完成服務
    case noShow           // 未到店
    case refunded         // 已退款
}


final class BookingService {
    private let db = Firestore.firestore()

    /// 建立一筆預約
    func createBooking(shopId: String,
                       serviceId: String,
                       startAt: Date,
                       duration: TimeInterval = 3600,
                       price: Int,
                       currency: String = "TWD",
                       completion: @escaping (Result<String, Error>) -> Void) {

        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.failure(NSError(domain: "Booking", code: 401, userInfo: [NSLocalizedDescriptionKey: "尚未登入"])))
        }

        let bookingId = "BK-\(UUID().uuidString.prefix(8))"
        let data: [String: Any] = [
            "bookingId": bookingId,
            "customerUid": uid,
            "shopId": shopId,
            "serviceId": serviceId,
            "startAt": Timestamp(date: startAt),
            "endAt": Timestamp(date: startAt.addingTimeInterval(duration)),
            "status": BookingStatus.pendingPayment.rawValue,
            "price": price,
            "currency": currency,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        db.collection("bookings").document(bookingId).setData(data) { err in
            if let err = err { completion(.failure(err)) }
            else { completion(.success(bookingId)) }
        }
    }
}
