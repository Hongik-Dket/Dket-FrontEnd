//
//  TicketDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/4/25.
//

import Foundation

struct TicketDetailDTO: Decodable {
    let ticketId: Int64
    let eventTitle: String
    let eventDateTime: Date
    let buyerName: String
    let birth: Date
    let ticketNumber: String
    let seatNumber: String
    let qrCodeUrl: String
    let photoCardId: Int64
    let nftUrl: String
    let entered: Bool
    
    var domain: TicketDetail {
        TicketDetail(
            ticketId: ticketId,
            eventTitle: eventTitle,
            eventDateTime: eventDateTime,
            buyerName: buyerName,
            birth: birth,
            ticketNumber: ticketNumber,
            seatNumber: seatNumber,
            qrCodeUrl: qrCodeUrl,
            photoCardId: photoCardId,
            nftUrl: nftUrl,
            entered: entered
        )
    }
}
