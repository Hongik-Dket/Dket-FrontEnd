//
//  BuyerEventDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

struct BuyerConcertDetailDTO: Decodable {
    let concertId: Int64
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
    let concertStatus: ConcertStatus
    
    let sessionList: [BuyerSessionDetailDTO]
    
    enum CodingKeys: String, CodingKey {
        case concertId, title, description, posterUrl, location,
             startDate, endDate, startTime, endTime,
             ageLimit, priceKrw, applyStart, applyEnd,
             capacity, concertStatus, sessionList
    }
}

extension BuyerConcertDetailDTO {
    var domain: ConcertDetail {
        ConcertDetail(
            id: concertId,
            title: title,
            poster: posterUrl,
            location: location,
            period: startDate ... endDate,
            timeRange: (startTime, endTime),
            ageLimit: ageLimit,
            priceKrw: priceKrw,
            applyPeriod: applyStart ... applyEnd,
            capacity: capacity,
            status: concertStatus,
            sessionIds: sessionList.map { $0.sessionId }  // sessionId만 추출
        )
    }
    
    var sessionDomainList: [BuyerSessionDetail] {
        sessionList.map { $0.domain }
    }
}
