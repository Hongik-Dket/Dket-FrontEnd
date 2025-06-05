//
//  EventDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

struct EventDetailDTO: Decodable {
    let eventId: Int64
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
    let eventStatus: EventStatus
    let sessionIds: [Int64]
    
    enum CodingKeys: String, CodingKey {
        case eventId, title, posterUrl, location,
             startDate, endDate, startTime, endTime,
             ageLimit, priceKrw, applyStart, applyEnd,
             capacity, eventStatus, sessionIds
    }
}


extension EventDetailDTO {
    var domain: EventDetail {
        .init(id: eventId,
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
              sessionIds: sessionIds)
    }
}

