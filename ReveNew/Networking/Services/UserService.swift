//
//  CloudflareServices.swift
//  ReveNew
//
//  Created by Pietro Messineo on 03/03/24.
//

import Foundation

struct UserService: HTTPClient {
    
    // MARK: - Create User
    func createUser() async throws -> CreateUserResponse {
        return try await request(
            endpoint: UserEndpoint.createUser,
            responseModel: CreateUserResponse.self
        )
    }
    
    // MARK: - Update Push
    func updatePushToken() async throws -> CreateUserResponse {
        return try await request(
            endpoint: UserEndpoint.updatePushToken,
            responseModel: CreateUserResponse.self
        )
    }
    
    // MARK: - Get App List
    func getAppList() async throws -> AppListResponse {
        return try await request(
            endpoint: UserEndpoint.appList,
            responseModel: AppListResponse.self
        )
    }
    
    // MARK: - Get Downloads
    func getDownloads(appName: String? = nil, startDate: Date? = nil, endDate: Date? = nil, groupBy: DownloadGrouping = .day, includeDetails: Bool = false) async throws -> DownloadResponse {
        let customJsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"

        customJsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = dateFormatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date format")
            }
        }
        
        return try await request(
            endpoint: UserEndpoint.getDownloads(appName: appName, startDate: startDate, endDate: endDate, groupBy: groupBy, includeDetails: includeDetails),
            responseModel: DownloadResponse.self,
            decoder: customJsonDecoder
        )
    }
    
    // MARK: - Get Purchases
    func getPurchases(appName: String, page: Int, startDate: Date? = nil, endDate: Date? = nil, includeSandbox: Bool = true) async throws -> PurchasesReponse {
        let customJsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"

        customJsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = dateFormatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date format")
            }
        }
        
        return try await request(endpoint: UserEndpoint.getPurchases(appName: appName, page: page, startDate: startDate, endDate: endDate, includeSandbox: includeSandbox), responseModel: PurchasesReponse.self, decoder: customJsonDecoder)
    }
    
    func getSummary(appName: String, startDate: Date? = nil, endDate: Date? = nil, groupBy: FilterGroup? = nil, includeSandbox: Bool = true) async throws -> PurchaseSummaryResponse {
        let customJsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        customJsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = dateFormatter.date(from: dateString) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date format")
            }
        }
        
        return try await request(endpoint: UserEndpoint.getSummary(appName: appName, startDate: startDate, endDate: endDate, groupBy: groupBy, includeSandbox: includeSandbox), responseModel: PurchaseSummaryResponse.self, decoder: customJsonDecoder)
    }
}
