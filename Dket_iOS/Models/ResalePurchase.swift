//
//  ResaleTicketDetail.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

struct ResalePurchase {
    let concertTitle: String
    let location: String
    let date: String
    let startTime: String
    let seatNumber: String
    let originalPrice: Int
    let resalePrice: Int
    let priceWei: Int64
    let photoCardUrl: URL?
}
