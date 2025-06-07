//
//  PurchaseSummaryResponse.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/4/25.
//

import Foundation

struct PurchaseSummaryResponse: Codable {
    let success: Bool
    let grouped: [PurchaseSummary]
}

struct PurchaseSummary: Codable, Hashable {
    let group: Date
    let totalInUSD: Double
    let count: Int
    let trialCount: Int
    let paidCount: Int
}
