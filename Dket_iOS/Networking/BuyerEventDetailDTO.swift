//
//  BuyerEventDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

struct BuyerEventDetailDTO: Decodable {
    let eventId: Int64
    let title: String
    let description: String
    let posterUrl: URL
    let location: String
    let startDate: Date
    let endDate:   Date
    let startTime: String
    let endTime:   String
    let ageLimit:  AgeLimit
    let priceKrw:     Int
    let applyStart: Date
    let applyEnd:   Date
    let capacity:   Int
    let eventStatus: EventStatus
    
    let sessionList: [BuyerSessionDetailDTO]
    
    enum CodingKeys: String, CodingKey {
        case eventId, title, description, posterUrl, location,
             startDate, endDate, startTime, endTime,
             ageLimit, priceKrw, applyStart, applyEnd,
             capacity, eventStatus, sessionList
    }
}

extension BuyerEventDetailDTO {
    var domain: EventDetail {
        EventDetail(
            id: eventId,
            title: title,
            poster: posterUrl,
            location: location,
            period: startDate ... endDate,
            timeRange: (startTime, endTime),
            ageLimit: ageLimit,
            priceKrw: priceKrw,
            applyPeriod: applyStart ... applyEnd,
            capacity: capacity,
            status: eventStatus,
            sessionIds: sessionList.map { $0.sessionId }  // sessionId만 추출
        )
    }
    
    var sessionDomainList: [BuyerSessionDetail] {
        sessionList.map { $0.domain }
    }
}
