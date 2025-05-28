//
//  AppListResponse.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/3/25.
//

import Foundation

struct AppListResponse: Codable {
    let success: Bool
    let apps: [String]
}
