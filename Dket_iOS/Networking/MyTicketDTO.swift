//
//  MyTicketDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

struct MyTicketDTO: Decodable {
    let ticketId: Int64
    let eventTitle: String
    let posterUrl: String
    let location: String
    let sessionDate: Date    // LocalDate → String
    let startTime: String      // LocalTime → String
    let entered: Bool
    
    // 도메인 객체로 변환
    var domain: MyTicket {
        let parsedStartTime = DateFormatter.hhmmss.date(from: startTime) ?? Date()
        return MyTicket(
            ticketId: ticketId,
            eventTitle: eventTitle,
            posterUrl: posterUrl,
            location: location,
            sessionDate: sessionDate,
            startTime: parsedStartTime,
            entered: entered
        )
    }
}
