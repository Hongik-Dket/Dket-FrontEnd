//
//  DateFormatter.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    static let yyyyMMddHHmm: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return f
    }()
}
