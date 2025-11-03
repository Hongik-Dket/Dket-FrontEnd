//
//  ResaleTicketDetailDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

struct ResalePurchaseDTO: Decodable {
    let concertTitle: String
    let location: String
    let date: String
    let startTime: String
    let seatNumber: String
    let originalPrice: Int
    let price: Int
    let priceWei: Int64
    let photoCardUrl: String
}

extension ResalePurchaseDTO {
    var domain: ResalePurchase {
        ResalePurchase(
            concertTitle: concertTitle,
            location: location,
            date: date,
            startTime: startTime,
            seatNumber: seatNumber,
            originalPrice: originalPrice,
            resalePrice: price,
            priceWei: priceWei,
            photoCardUrl: URL(string: photoCardUrl)
        )
    }
}
