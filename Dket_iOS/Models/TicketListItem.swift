//
//  TicketListItem.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

struct TicketListItem: Identifiable {
    
    var id: Int64 { ticketId }
    let ticketId: Int64
    let title: String
    let location: String
    let dateFormatted: String
    let imageUrl: String?
    let entered: Bool
}
