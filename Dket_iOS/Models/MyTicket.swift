//
//  MyTicket.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

struct MyTicket: Identifiable {
    var id: Int64 { ticketId }

    let ticketId: Int64
    let eventTitle: String
    let posterUrl: String
    let location: String
    let sessionDate: Date
    let startTime: Date
    let entered: Bool
    
    var sessionDateFormatted: String {
        DateFormatter.yyyyDMMDdd.string(from: sessionDate)
    }
    
    var startTimeFormatted: String {
        DateFormatter.hhmmss.string(from: startTime)
    }
}
