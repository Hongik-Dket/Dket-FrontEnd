//
//  BuyerSessionDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

struct BuyerSessionDetailDTO: Decodable {
    let sessionId: Int64
    let date: Date  // "yyyy-MM-dd"
    
    let applyStatus: ApplyStatus?
    let ticketId: Int64?
    let paidCount: Int
    let buyable: Bool

    enum CodingKeys: String, CodingKey {
        case sessionId, date
        case applyStatus, ticketId, paidCount, buyable
    }
}

extension BuyerSessionDetailDTO {
    var domain: BuyerSessionDetail {
        BuyerSessionDetail(
            id: sessionId,
            date: date,
            applyStatus: applyStatus?.domain,
            ticketId: ticketId,
            paidCount: paidCount,
            buyable: buyable,
            remainingTickets: 0
        )
    }
}
