//
//  EventStatus.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

enum EventStatus: String, Decodable {
    case applyNotOpened  = "APPLY_NOT_OPENED"   // 응모 전
    case applyOpen       = "APPLY_OPEN"         // 응모 중 (D-N)
    case applyClosed     = "APPLY_CLOSED"       // 응모 마감
    case ticketed        = "TICKETED"           // 예매 완료
    case inProgress      = "IN_PROGRESS"        // 공연 중
    case ended           = "ENDED"              // 공연 종료
    
    var label: String {
        switch self {
        case .applyNotOpened: "응모 전"
        case .applyOpen:      "응모 중"
        case .applyClosed:    "응모 마감"
        case .ticketed:       "선착순 판매"
        case .inProgress:     "공연 중"
        case .ended:          "공연 종료"
        }
    }
}

