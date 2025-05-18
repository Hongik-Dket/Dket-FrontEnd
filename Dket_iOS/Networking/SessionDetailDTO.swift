//
//  SessionDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

struct SessionDetailDTO: Decodable {
    let eventId:      Int64
    let sessionId:    Int64
    let date:         Date        // yyyy-MM-dd
    let applyCount:   Int
    let paidCount:    Int?
    let attendeeCount:Int?
    
    enum CodingKeys: String, CodingKey {
        case eventId, sessionId, date,
             applyCount, paidCount, attendeeCount
    }
}

extension SessionDetailDTO {
    var domain: SessionDetail {
        SessionDetail(
            eventId: eventId,
            id:      sessionId,
            date:    date,
            applyCount:    applyCount,
            paidCount:     paidCount,
            attendeeCount: attendeeCount
        )
    }
}
