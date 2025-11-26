//
//  BuyerTicketDetailDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/26/25.
//

import Foundation

struct BuyerTicketDetailDTO: Decodable {
    let ticketId: Int64
    let concertTitle: String
    let sessionId: Int64
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
        case ticketId, concertTitle, sessionId, concertDateTime, buyerName, birth,
             ticketNumber, seatNumber, nftUrl, photoCardUrl, price, isResaleListed
        case isEntered = "entered"
    }

    var domain: BuyerTicketDetail {
        BuyerTicketDetail(
            ticketId: ticketId,
            concertTitle: concertTitle,
            sessionId: sessionId,
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


struct BuyerTicketDetail: Equatable {
    let ticketId: Int64
    let concertTitle: String
    let sessionId: Int64
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

    var birthDateFormatted: String {
        DateFormatter.yyyyDMMDdd.string(from: birth)
    }

    var startDateFormatted: String {
        DateFormatter.yyyyDMMDddHHmm.string(from: concertDateTime)
    }
}
