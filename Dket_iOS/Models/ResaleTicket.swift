//
//  ResaleTicket.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

struct ResaleTicket: Identifiable {
    let id: Int
    let price: Int
    let seatNumber: Int
    let isAvailable: Bool
    let photoCardURL: URL?
}
