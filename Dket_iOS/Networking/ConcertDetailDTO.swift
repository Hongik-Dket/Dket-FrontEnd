//
//  EventDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

struct ConcertDetailDTO: Decodable {
    let concertId: Int64
    let title: String
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
    let sessionIds: [Int64]
    let description: String
    let photoCardList: [PhotoCardItemDTO]
    let isResaleAllowed: Bool
    
    enum CodingKeys: String, CodingKey {
        case concertId, title, posterUrl, location,
             startDate, endDate, startTime, endTime,
             ageLimit, priceKrw, applyStart, applyEnd,
             capacity, concertStatus, sessionIds,
             description, photoCardList, isResaleAllowed
    }
}


extension ConcertDetailDTO {
    var domain: ConcertDetail {
        .init(id: concertId,
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
              sessionIds: sessionIds,
              description: description,
              photoCards: photoCardList.map { $0.toDomain()},
              isResaleAllowed: isResaleAllowed
        )
    }
}
