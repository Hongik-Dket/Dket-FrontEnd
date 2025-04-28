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
    let startTime: String        // "18:00:00"
    let endTime:   String
    let ageLimit:  AgeLimit
    let price:     Int
    let applyStart: Date
    let applyEnd:   Date
    let capacity:   Int
    let eventStatus: EventStatus
    let sessionIds: [Int64]
    
    enum CodingKeys: String, CodingKey {
        case eventId, title, posterUrl, location,
             startDate, endDate, startTime, endTime,
             ageLimit, price, applyStart, applyEnd,
             capacity, eventStatus, sessionIds
    }
}

extension EventDetailDTO {
    var domain: EventDetail {
        EventDetail(
            id: eventId,
            title: title,
            posterUrl: posterUrl,
            location: location,
            period: startDate ... endDate,
            startTime: DateFormatter.hhmmss.date(from: startTime)!,
            endTime:   DateFormatter.hhmmss.date(from: endTime)!,
            ageLimit:  ageLimit,
            price:     price,
            applyStart: applyStart,
            applyEnd:   applyEnd,
            capacity:   capacity,
            status:     eventStatus,
            sessionIds: sessionIds
        )
    }
}
