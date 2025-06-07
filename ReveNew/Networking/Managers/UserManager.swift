//
//  UserManager.swift
//  ReveNew
//
//  Created by Pietro Messineo on 03/03/24.
//

import Foundation
import FirebaseAnalytics

@MainActor
final class UserManager: ObservableObject {
    let service = UserService()
    
    @Published var errorMessage: String?
    @Published var showErrorMessage: Bool = false
    @Published var appList: [String] = []
    @Published var purchases: [Purchase] = []
    @Published var purchaseResponse: PurchasesReponse?
    @Published var purchaseSummaryResponse: PurchaseSummaryResponse?
    @Published var downloadResponse: DownloadResponse?
    
    // Loading status
    @Published var isLoading = false
    
    /// Create user
    func createUser() async throws {
        let userCreation = try await service.createUser()
        print("User creation status - \(userCreation.message)")
    }
    
    /// Update push token
    func updatePushToken() async throws {
        let updatePushToken = try await service.updatePushToken()
        print("Push token update - \(updatePushToken.message)")
    }
    
    /// Retrieve the list of All Apps
    func getAppList() async throws {
        let appList = try await service.getAppList()
        self.appList = appList.apps
    }
    
    /// Get Downloads
    func getDownloads(appName: String? = nil, startDate: Date? = nil, endDate: Date? = nil, groupBy: DownloadGrouping = .day, includeDetails: Bool = false) async throws {
        let downloadResponse = try await service.getDownloads(appName: appName, startDate: startDate, endDate: endDate, groupBy: groupBy, includeDetails: includeDetails)
        self.downloadResponse = downloadResponse
    }
    
    /// Get Purchases
    func getPurchases(appName: String, page: Int, startDate: Date? = nil, endDate: Date? = nil, includeSandbox: Bool = true, includeTrials: Bool = true, trialStatus: TrialStatus = .all) async throws {
        if page == 1 {
            purchases.removeAll()
        }
        
        let purchasesResponse = try await service.getPurchases(appName: appName, page: page, startDate: startDate, endDate: endDate, includeSandbox: includeSandbox, includeTrials: includeTrials, trialStatus: trialStatus)
        
        self.purchaseResponse = purchasesResponse
        
        if let purchases = purchasesResponse.purchases {
            self.purchases.append(contentsOf: purchases)
        }
    }
    
    /// Get Summary
    func getPurchaseSummary(appName: String, startDate: Date? = nil, endDate: Date? = nil, groupBy: FilterGroup? = nil, includeSandbox: Bool = true) async throws {
        let purchaseSummary = try await service.getSummary(appName: appName, startDate: startDate, endDate: endDate, groupBy: groupBy, includeSandbox: includeSandbox)
        self.purchaseSummaryResponse = purchaseSummary
    }
}
