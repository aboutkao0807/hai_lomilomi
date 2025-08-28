//
//  AuthService.swift
//  hai_lomilomi
//
//  Created by Macintosh on 2025/8/23.
//

import UIKit              // ← 補上這行
import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

enum AuthError: Error, LocalizedError {
    case missingClientID
    case googleFailed(String)
    case firebaseFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingClientID: return "找不到 Firebase clientID，請確認已加入 GoogleService-Info.plist"
        case .googleFailed(let msg): return "Google 登入失敗：\(msg)"
        case .firebaseFailed(let msg): return "Firebase 錯誤：\(msg)"
        }
    }
}

final class AuthService {
    /// 回傳 (user, isNewUser)
    func signInGoogle(presenting: UIViewController,
                      completion: @escaping (Result<(User, Bool), AuthError>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return completion(.failure(.missingClientID))
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            if let error = error {
                return completion(.failure(.googleFailed(error.localizedDescription)))
            }

            guard let gidUser = result?.user else {
                return completion(.failure(.googleFailed("無法取得 Google 使用者")))
            }

            guard let idToken = gidUser.idToken?.tokenString else {
                return completion(.failure(.googleFailed("無法取得 Google ID Token")))
            }

            let accessToken = gidUser.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    return completion(.failure(.firebaseFailed(error.localizedDescription)))
                }
                guard let user = authResult?.user else {
                    return completion(.failure(.firebaseFailed("無法取得使用者")))
                }
                let isNew = authResult?.additionalUserInfo?.isNewUser ?? false
                completion(.success((user, isNew)))
            }
        }
    }
}
