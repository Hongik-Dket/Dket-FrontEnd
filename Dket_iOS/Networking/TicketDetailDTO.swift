//
//  TicketDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/4/25.
//

import Foundation

struct TicketDetailDTO: Decodable {
    let ticketId:     Int64
    let eventTitle:   String
    let eventDateTime: Date
    let buyerName:    String
    let birth:        Date
    let ticketNumber: String
    let seatNumber:   String
    let qrCodeUrl:    String?

    var domain: TicketDetail {
        TicketDetail(
            id: ticketId,
            title: eventTitle,
            dateFormatted: DateFormatter.yyyyDMMDddHHmm.string(from: eventDateTime),
            userName: buyerName,
            userBirth: DateFormatter.yyyyDMMDdd.string(from: birth),
            ticketNumber: ticketNumber,
            seat: seatNumber,
            qrCodeUrl: qrCodeUrl
        )
    }
}
