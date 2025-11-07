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
    let startDate: String   // ✅ String으로 변경
    let endDate:   String   // ✅ String으로 변경
    let startTime: String
    let endTime:   String
    let ageLimit:  AgeLimit
    let priceKrw:  Int
    let applyStart: String  // ✅ String으로 변경
    let applyEnd:   String  // ✅ String으로 변경
    let capacity:   Int
    let concertStatus: ConcertStatus
    let sessionIds: [Int64]
    let description: String
    let photoCardList: [PhotoCardItemDTO]
    let isResaleAllowed: Bool
}


extension ConcertDetailDTO {
    var domain: ConcertDetail {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let start = formatter.date(from: startDate) ?? .now
        let end = formatter.date(from: endDate) ?? .now
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let applyStartDate = dateTimeFormatter.date(from: applyStart) ?? .now
        let applyEndDate = dateTimeFormatter.date(from: applyEnd) ?? .now
        
        return ConcertDetail(
            id: concertId,
            title: title,
            poster: posterUrl,
            location: location,
            period: start ... end,
            timeRange: (startTime, endTime),
            ageLimit: ageLimit,
            priceKrw: priceKrw,
            applyPeriod: applyStartDate ... applyEndDate,
            capacity: capacity,
            status: concertStatus,
            sessionIds: sessionIds,
            description: description,
            photoCards: photoCardList.map { $0.toDomain() },
            isResaleAllowed: isResaleAllowed
        )
    }
}
