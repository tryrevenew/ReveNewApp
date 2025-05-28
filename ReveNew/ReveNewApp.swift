//
//  ReveNewApp.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/2/25.
//

import SwiftUI
import Firebase
import FirebaseMessaging

@main
struct ReveNewApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var authManager: AuthManager = AuthManager()
    @StateObject var userManager: UserManager = UserManager()
    
    @AppStorage("selectedApp") var appName: String?
    
    init() {
        // Configure your network settings
        // NetworkConfiguration.shared.configure(host: "api.revenew.com", port: 2025)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if !authManager.isAuthenticated {
                    SignInView()
                } else {
                    if let appName {
                        HomeView()
                    } else {
                        AppListSelectionView()
                    }
                }
            }
            .environmentObject(authManager)
            .environmentObject(userManager)
            .onChange(of: authManager.isAuthenticated) { _ , isAuthenticated in
                if isAuthenticated {
                    Task {
                        try await userManager.createUser()
                    }
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    
    let profileManager = UserManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                print("is granted \(granted) AND ERROR \(String(describing: error?.localizedDescription))")
            }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("I got FCM Token \(String(data: deviceToken, encoding: .utf8))")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // MARK: - Create user here if we get registration token
        if let fcmToken {
            AppData.shared.fcmToken = fcmToken
            print("I DID RECEIVE FCM Token \(fcmToken)")
            // MARK: - Refresh token
            if let currentUser = AppData.shared.userToken {
                print("Update Push Token")
                Task {
                    do {
                        try await profileManager.updatePushToken()
                    } catch {
                        print("Error updating push token \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // Handle remote notification registration fail.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error.localizedDescription)")
    }
}
