//
//  EventCreateRequestDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/30/25.
//

import Foundation

struct ConcertCreateRequestDTO: Encodable {
    let title: String
    let ageLimit: AgeLimit
    let location: String
    let description: String
    let startDate: Date
    let endDate: Date
    let startTime: String
    let endTime: String
    let priceKrw: Int
    let capacity: Int
    let applyStart: Date
    let applyEnd: Date
    let isResaleAllowed: Bool
    
    enum CodingKeys: String, CodingKey {
        case title, ageLimit, location, description
        case startDate, endDate, startTime, endTime
        case priceKrw, capacity, applyStart, applyEnd, isResaleAllowed
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(title, forKey: .title)
        try c.encode(ageLimit, forKey: .ageLimit)
        try c.encode(location, forKey: .location)
        try c.encode(description, forKey: .description)
        try c.encode(startTime, forKey: .startTime)
        try c.encode(endTime, forKey: .endTime)
        try c.encode(priceKrw, forKey: .priceKrw)
        try c.encode(capacity, forKey: .capacity)
        try c.encode(isResaleAllowed, forKey: .isResaleAllowed)
        try c.encode(DateFormatter.yyyyMMdd.string(from: startDate), forKey: .startDate)
        try c.encode(DateFormatter.yyyyMMdd.string(from: endDate), forKey: .endDate)
        try c.encode(DateFormatter.yyyyMMddTHHmmss.string(from: applyStart), forKey: .applyStart)
        try c.encode(DateFormatter.yyyyMMddTHHmmss.string(from: applyEnd), forKey: .applyEnd)
    }
}



struct ConcertCreateResponseDTO: Decodable {
    let concertId: Int64
}

typealias CreateConcertResponseDTO = APIResponse<ConcertCreateResponseDTO>

