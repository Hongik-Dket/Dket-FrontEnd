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
    let bannerUrl: URL
    let eventStatus: EventStatus?      // home 에선 nil
    let applyStart: Date?
    let applyEnd: Date?
}

extension EventDTO {
    var domain: Event {
        Event(id: eventId,
              title: title,
              location: location,
              period: startDate ... endDate,
              bannerURL: bannerUrl,
              status: eventStatus,
              applyPeriod: {
                  guard let s = applyStart, let e = applyEnd else { return nil }
                  return s ... e
              }())
    }
}

