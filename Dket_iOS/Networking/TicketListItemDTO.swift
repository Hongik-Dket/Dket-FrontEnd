//
//  TicketListItemDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import Foundation

struct TicketListItemDTO: Decodable {
    let ticketId: Int64
    let title: String
    let location: String
    let eventDateTime: Date
    let imageUrl: String?
    let entered: Bool
    
    var domain: TicketListItem {
        TicketListItem(
            ticketId: ticketId,
            title: title,
            location: location,
            dateFormatted: DateFormatter.yyyyDMMDddHHmm.string(from: eventDateTime),
            imageUrl: imageUrl,
            entered: entered
        )
    }
}
