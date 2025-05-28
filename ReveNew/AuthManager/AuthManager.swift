//
//  RemoteConfigManager.swift
//  ReveNew
//
//  Created by Pietro Messineo on 2/5/25.
//

import Foundation
import FirebaseAuth
import SwiftUI
import AuthenticationServices
import CryptoKit
import Firebase

public final class AuthManager: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published public var isAuthenticated: Bool = false
    @Published public var currentUser: User?
    @Published public var isLoading: Bool = false

    private var currentNonce: String?

    override public init() {
        super.init()
        Auth.auth().addStateDidChangeListener { _, user in
            Task { @MainActor in
                self.currentUser = user
                self.isAuthenticated = (user != nil)
                AppData.shared.email = user?.email
                AppData.shared.userToken = user?.uid
                print("Auth state changed: isAuthenticated = \(self.isAuthenticated)")
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }

    public func startSignInWithAppleFlow() {
        isLoading = true
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("Apple Sign-In failed: Invalid credentials")
            self.isLoading = false
            return
        }

        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            self.isLoading = false
            return
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            self.isLoading = false
            return
        }
        
        let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: nonce)

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                } else {
                    print("Apple sign in successful.")
                }
            }
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            print("Sign in with Apple errored: \(error.localizedDescription)")
        }
    }

    public func logout() async throws {
        isLoading = true
        do {
            try Auth.auth().signOut()
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Error logging out: \(error.localizedDescription)")
        }
    }

    public func deleteAccount() async throws {
        isLoading = true
        do {
            try await Auth.auth().currentUser?.delete()
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Error deleting account: \(error.localizedDescription)")
        }
    }
}
