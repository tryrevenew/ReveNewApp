//
//  AppData.swift
//
//  Created by Pietro Messineo on 5/2/25.
//

import Foundation

class AppData {
    static let shared = AppData()
    
    var userToken: String?
    var email: String?
    var fcmToken: String = ""
}
