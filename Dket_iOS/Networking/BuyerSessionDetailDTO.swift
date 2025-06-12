//
//  BuyerSessionDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

struct BuyerSessionDetailDTO: Decodable {
    let eventId: Int64
    let sessionId: Int64
    let date: Date  // "yyyy-MM-dd"
    
    let applyStatus: ApplyStatus?
    let ticketId: Int64?
    let paidCount: Int

    enum CodingKeys: String, CodingKey {
        case eventId, sessionId, date
        case applyStatus, ticketId, paidCount
    }
}

extension BuyerSessionDetailDTO {
    var domain: BuyerSessionDetail {
        BuyerSessionDetail(
            eventId: eventId,
            id: sessionId,
            date: date,
            applyStatus: applyStatus?.domain,
            ticketId: ticketId,
            paidCount: paidCount
        )
    }
}
