//
//  EventDetail.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

struct ConcertDetail {
    let id: Int64
    let title: String
    let poster: URL
    let location: String
    let period: ClosedRange<Date>
    let timeRange: (start: String, end: String)
    let ageLimit: AgeLimit
    let priceKrw: Int
    let applyPeriod: ClosedRange<Date>
    let capacity: Int
    let status: ConcertStatus
    let sessionIds: [Int64]
    let description: String               
    let photoCards: [PhotoCardItem]
    let isResaleAllowed: Bool
}

