//
//  Ticket.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import Foundation

struct TicketDetail: Identifiable {
    let id: Int64
    let title:        String
    let dateFormatted: String
    let userName:     String
    let userBirth:    String
    let ticketNumber: String
    let seat:         String
    let qrCodeUrl:    String?
}

