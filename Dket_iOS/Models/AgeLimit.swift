//
//  AgeLimit.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

enum AgeLimit: String, Codable {
    case all     = "ALL"
    case age12   = "AGE_12"
    case age15   = "AGE_15"
    case age18   = "AGE_18"
    
    var label: String {
        switch self {
        case .all:   "전체 관람"
        case .age12: "12세 이상"
        case .age15: "15세 이상"
        case .age18: "18세 이상"
        }
    }
}
