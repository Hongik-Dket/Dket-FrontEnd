//
//  Ticket.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import Foundation

struct TicketDetail: Equatable {
    let ticketId: Int64
    let concertTitle: String
    let concertDateTime: Date
    let buyerName: String
    let birth: Date
    let ticketNumber: String
    let seatNumber: String
    let qrCodeUrl: String?
    let photoCardId: Int64
    let nftUrl: String
    let entered: Bool
    
    var birthDateFormatted: String {
        DateFormatter.yyyyDMMDddHHmm.string(from: birth)
    }
    
    var startDateFormatted: String {
        DateFormatter.yyyyDMMDddHHmm.string(from: conertDateTime)
    }
}

