//
//  Date+Extension.swift
//  ReveNew
//
//  Created by Pietro Messineo on 5/3/25.
//

import Foundation

extension Date {
    func timeAgo(short: Bool = true) -> String {
        let now = Date()
        let seconds = Int(now.timeIntervalSince(self))

        switch seconds {
        case ..<5:
            return "now"
        case ..<60:
            return "\(seconds)s ago"
        case ..<3600:
            return "\(seconds / 60)m ago"
        case ..<86400:
            return "\(seconds / 3600)h ago"
        case ..<604800:
            return "\(seconds / 86400)d ago"
        default:
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: self)
        }
    }
    
    func toMonthDayYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        formatter.locale = Locale(identifier: "en_US") // Ensure English month names
        
        return formatter.string(from: self)
    }
    
    func shortLabel() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let output = DateFormatter()
        output.dateFormat = "d MMM" // e.g. "2 May"
        
        return output.string(from: self)
    }
    
    func shortTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
}
