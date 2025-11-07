//
//  ResaleTicketInfo.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import Foundation

struct ResaleTicketInfo: Identifiable {
    let id = UUID()
    let resaleId: Int64
    let concertTitle: String
    let location: String
    let date: String
    let startTime: String
    let seatCode: String
    let originalPrice: Int
    let priceKrw: Int
    let priceWei: Int64          
    let photoCardUrl: URL?
}
