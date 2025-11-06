//
//  ResaleTicket.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

struct ResaleTicket: Identifiable, Equatable {
    let id: Int64
    let ticketId: Int64
    let price: Int
    let seatCode: String
    let status: ResaleStatus
    let photoCardUrl: URL?
}
