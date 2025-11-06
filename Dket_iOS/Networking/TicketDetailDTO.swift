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
    let nftUrl: String
    let isEntered: Bool         
    let photoCardUrl: String
    let price: Int
    let isResaleListed: Bool

    enum CodingKeys: String, CodingKey {
        case ticketId, concertTitle, concertDateTime, buyerName, birth,
             ticketNumber, seatNumber, nftUrl, photoCardUrl, price, isResaleListed
        case isEntered = "entered"
    }
    
    var domain: TicketDetail {
        TicketDetail(
            ticketId: ticketId,
            concertTitle: concertTitle,
            concertDateTime: concertDateTime,
            buyerName: buyerName,
            birth: birth,
            ticketNumber: ticketNumber,
            seatNumber: seatNumber,
            nftUrl: nftUrl,
            isEntered: isEntered,
            photoCardUrl: photoCardUrl,
            price: price,
            isResaleListed: isResaleListed
        )
    }
}
