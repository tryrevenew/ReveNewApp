//
//  UserEndpoint.swift
//  ReveNew
//
//  Created by Pietro Messineo on 03/03/24.
//

import Foundation

// hour, day, week, or month
enum FilterGroup: String, CaseIterable {
    case day
    case hour
    case month
}

enum UserEndpoint {
    case createUser
    case updatePushToken
    case appList
    case getPurchases(appName: String, page: Int, startDate: Date? = nil, endDate: Date? = nil, includeSandbox: Bool = true)
    case getSummary(appName: String, startDate: Date?, endDate: Date?, groupBy: FilterGroup?, includeSandbox: Bool = true)
    case getDownloads(appName: String?, startDate: Date? = nil, endDate: Date? = nil, groupBy: DownloadGrouping = .day, includeDetails: Bool = false)
}

extension UserEndpoint: Endpoint {
    var port: Int {
        return NetworkConfiguration.shared.getPort()
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .createUser, .updatePushToken, .appList:
            return nil
        case .getPurchases(let appName, let page, let startDate, let endDate, let includeSandbox):
            var defaultQueries = [
                URLQueryItem(name: "appName", value: appName),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "10"),
                URLQueryItem(name: "includeSandbox", value: includeSandbox ? "true" : "false")
            ]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            if let startDate = startDate {
                defaultQueries.append(URLQueryItem(name: "startDate", value: formatter.string(from: startDate)))
            }
            
            if let endDate = endDate {
                defaultQueries.append(URLQueryItem(name: "endDate", value: formatter.string(from: endDate)))
            }
            
            return defaultQueries
        case .getSummary(let appName, let startDate, let endDate, let groupBy, let includeSandbox):
            var defaultQueries = [
                URLQueryItem(name: "appName", value: appName),
                URLQueryItem(name: "includeSandbox", value: includeSandbox ? "true" : "false")
            ]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            if let startDate = startDate {
                defaultQueries.append(URLQueryItem(name: "startDate", value: formatter.string(from: startDate)))
            }
            
            if let endDate = endDate {
                defaultQueries.append(URLQueryItem(name: "endDate", value: formatter.string(from: endDate)))
            }
            
            if let groupBy = groupBy {
                defaultQueries.append(URLQueryItem(name: "groupBy", value: groupBy.rawValue))
            }
            
            return defaultQueries
        case .getDownloads(let appName, let startDate, let endDate, let groupBy, let includeDetails):
            var defaultQueries = [
                URLQueryItem(name: "groupBy", value: groupBy.rawValue),
                URLQueryItem(name: "includeDetails", value: includeDetails ? "true" : "false")
            ]
            
            if let appName = appName {
                defaultQueries.append(URLQueryItem(name: "appName", value: appName))
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            if let startDate = startDate {
                defaultQueries.append(URLQueryItem(name: "startDate", value: formatter.string(from: startDate)))
            }
            
            if let endDate = endDate {
                defaultQueries.append(URLQueryItem(name: "endDate", value: formatter.string(from: endDate)))
            }
            
            return defaultQueries
        }
    }
    
    var path: String {
        switch self {
        case .createUser:
            return "/api/v1/create-user"
        case .updatePushToken:
            return "/api/v1/update-token"
        case .appList:
            return "/api/v1/apps"
        case .getPurchases:
            return "/api/v1/purchases"
        case .getSummary:
            return "/api/v1/purchases/summary"
        case .getDownloads:
            return "/api/v1/downloads"
        }
    }

    var method: RequestMethod {
        switch self {
        case .createUser:
            return .post
        case .updatePushToken:
            return .put
        case .appList, .getPurchases, .getSummary, .getDownloads:
            return .get
        }
    }

    var header: [String: String]? {
        switch self {
        case .createUser, .updatePushToken, .appList, .getPurchases, .getSummary, .getDownloads:
            return nil
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .createUser:
            return [
                "userId": AppData.shared.userToken ?? "",
                "email": AppData.shared.email ?? "",
                "userToken": AppData.shared.fcmToken
            ]
        case .updatePushToken:
            return [
                "userId": AppData.shared.userToken ?? "",
                "userToken": AppData.shared.fcmToken,
            ]
        case .appList, .getPurchases, .getSummary, .getDownloads:
            return nil
        }
    }
    
    func buildRequestBody() -> (Data?, contentType: String?) {
        switch self {
        default:
            if let body = body {
                let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])
                return (jsonData, "application/json")
            } else {
                return (nil, "application/json")
            }
        }
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
