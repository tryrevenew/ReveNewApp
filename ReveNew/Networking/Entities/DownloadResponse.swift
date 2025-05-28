import Foundation

enum DownloadGrouping: String, CaseIterable {
    case hour
    case day
    case week
    case month
    case total
}

struct DownloadResponse: Codable {
    let success: Bool
    let data: DownloadData
}

struct DownloadData: Codable {
    let downloads: [DownloadPeriod]
    let totalUniqueUsers: Int
    let periodType: String
    let startDate: Date
    let endDate: Date
}

struct DownloadPeriod: Codable {
    let period: String
    let uniqueUsers: Int
    let totalDownloads: Int
    let details: [DownloadDetail]?
}

struct DownloadDetail: Codable {
    let userId: String
    let timestamp: Date
    let appName: String
} 