//
//  ResaleTicketDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

struct ResaleTicketInfoDTO: Decodable {
    let resaleId: Int64
    let concertTitle: String
    let location: String
    let date: String
    let startTime: String
    let seatCode: String
    let originalPrice: Int
    let priceKrw: Int
    let priceWei: Int64
    let photoCardUrl: String

    var domain: ResaleTicketInfo {
        ResaleTicketInfo(
            resaleId: resaleId,
            concertTitle: concertTitle,
            location: location,
            date: date,
            startTime: startTime,
            seatCode: seatCode,
            originalPrice: originalPrice,
            priceKrw: priceKrw,
            priceWei: priceWei,
            photoCardUrl: URL(string: photoCardUrl)
        )
    }
}
