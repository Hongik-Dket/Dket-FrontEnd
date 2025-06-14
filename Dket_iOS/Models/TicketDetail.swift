//
//  Ticket.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import Foundation

struct TicketDetail: Identifiable {
    let id = UUID()  
    let title:        String
    let userName:     String
    let userBirth:    String
    let ticketNumber: String
    let seat:         String
    let qrCodeUrl:    String?
}

