//
//  PurchasesReponse.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/3/25.
//

import Foundation

struct PurchasesReponse: Codable {
    let success: Bool
    let purchases: [Purchase]?
    let totalInUSD: String?
}

struct Purchase: Codable, Hashable {
    let _id: String
    let currencyCode: String
    let price: Double
    let priceFormatted: String
    let kind: String
    let isSandbox: Bool
    let appName: String
    let createdAt: Date
    let storeFront: String?
}
