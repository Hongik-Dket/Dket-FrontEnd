//
//  MyTicketDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

struct MyTicketDTO: Decodable {
    let ticketId: Int64
    let concertTitle: String
    let posterUrl: String
    let location: String
    let sessionDate: Date
    let startTime: String
    let entered: Bool
    
    var domain: MyTicket {
        let parsedStartTime = DateFormatter.hhmmss.date(from: startTime) ?? Date()
        return MyTicket(
            ticketId: ticketId,
            concertTitle: concertTitle,
            posterUrl: posterUrl,
            location: location,
            sessionDate: sessionDate,
            startTime: parsedStartTime,
            entered: entered
        )
    }
}
