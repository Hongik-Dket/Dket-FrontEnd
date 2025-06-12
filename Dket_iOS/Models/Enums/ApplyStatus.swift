//
//  Untitled.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

enum ApplyStatus: String, Codable {
    case applied       = "APPLIED"       // 응모 완료
    case selected      = "SELECTED"      // 당첨됨, 결제 전
    case notSelected   = "NOT_SELECTED"  // 미당첨
    case paid          = "PAID"          // 결제 완료 (티켓 소유)
    case canceled      = "CANCELED"      // 당첨됐지만 결제 안해서 취소됨
    
    var domain: ApplyStatus {
        switch self {
        case .applied: return .applied
        case .selected: return .selected
        case .notSelected: return .notSelected
        case .paid: return .paid
        case .canceled: return .canceled
        }
    }
}
