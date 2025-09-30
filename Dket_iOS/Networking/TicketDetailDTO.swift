//
//  TicketDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/4/25.
//

import Foundation

struct TicketDetailDTO: Decodable {
    let ticketId: Int64
    let concertTitle: String
    let concertDateTime: Date
    let buyerName: String
    let birth: Date
    let ticketNumber: String
    let seatNumber: String
    let qrCodeUrl: String
    let photoCardId: Int64
    let nftUrl: String
    let entered: Bool
    let photoCardUrl: String
    let price: Int
    
    var domain: TicketDetail {
        TicketDetail(
            ticketId: ticketId,
            concertTitle: concertTitle,
            concertDateTime: concertDateTime,
            buyerName: buyerName,
            birth: birth,
            ticketNumber: ticketNumber,
            seatNumber: seatNumber,
            qrCodeUrl: qrCodeUrl,
            photoCardId: photoCardId,
            nftUrl: nftUrl,
            entered: entered,
            photoCardUrl: photoCardUrl,
            price: price
        )
    }
}
