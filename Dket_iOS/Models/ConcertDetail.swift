//
//  EventDetail.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

// MARK: - ConcertDetail Domain
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
    let photoCards: [PhotoCardInfo]
    let isResaleAllowed: Bool
}

// MARK: - Buyer 용 이니셜라이저 추가
extension ConcertDetail {
    init(
        id: Int64,
        title: String,
        poster: URL,
        location: String,
        period: ClosedRange<Date>,
        timeRange: (start: String, end: String),
        ageLimit: AgeLimit,
        priceKrw: Int,
        applyPeriod: ClosedRange<Date>,
        capacity: Int,
        status: ConcertStatus,
        sessionIds: [Int64],
        description: String,
        photoCards: [PhotoCardItem],        // ✅ Buyer용
        isResaleAllowed: Bool
    ) {
        self.id = id
        self.title = title
        self.poster = poster
        self.location = location
        self.period = period
        self.timeRange = timeRange
        self.ageLimit = ageLimit
        self.priceKrw = priceKrw
        self.applyPeriod = applyPeriod
        self.capacity = capacity
        self.status = status
        self.sessionIds = sessionIds
        self.description = description
        self.photoCards = photoCards.map { PhotoCardInfo(id: $0.photoCardId, imageUrl: $0.imageUrl) } // ✅ 변환 처리
        self.isResaleAllowed = isResaleAllowed
    }
}
