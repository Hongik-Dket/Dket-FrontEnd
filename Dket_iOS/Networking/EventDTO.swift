//
//  EventDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

struct EventDTO: Decodable {
    let eventId: Int64
    let title: String
    let location: String
    let startDate: Date
    let endDate: Date
    let imageUrl: URL
    let eventStatus: EventStatus?     
    
    enum CodingKeys: String, CodingKey {
            case eventId, title, location, startDate, endDate, imageUrl, eventStatus
        }
}

extension EventDTO {
    var domain: Event {
        Event(id: eventId,
              title: title,
              location: location,
              period: startDate ... endDate,
              imageUrl: imageUrl,
              status: eventStatus)
    }
}

