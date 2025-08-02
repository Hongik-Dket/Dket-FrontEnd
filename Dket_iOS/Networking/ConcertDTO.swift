//
//  EventDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

struct ConcertDTO: Decodable {
    let concertId: Int64
    let title: String
    let location: String
    let startDate: Date
    let endDate: Date
    let imageUrl: URL
    let concertStatus: ConcertStatus?
    
    enum CodingKeys: String, CodingKey {
            case concertId, title, location, startDate, endDate, imageUrl, concertStatus
        }
}

extension ConcertDTO {
    var domain: Concert {
        Concert(id: concertId,
              title: title,
              location: location,
              period: startDate ... endDate,
              imageUrl: imageUrl,
              status: concertStatus)
    }
}

