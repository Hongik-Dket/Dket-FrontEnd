//
//  ResaleLookUpDTO.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import UIKit

struct ResaleLookUpResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [ResaleTicketDTO]
}

struct ResaleCardDto: Decodable {
    let resaleId: Int64
    let ticketId: Int64
    let priceKrw: Int
    let seatCode: String
    let resaleStatus: ResaleStatus
    let photoCardUrl: String
}

enum ResaleStatus: String, Codable {
    case available = "AVAILABLE"   // 거래 가능
    case reserved = "RESERVED"     // 거래 진행 중 (온체인 대기)
    case sold = "SOLD"             // 판매 완료
}

extension ResaleCardDto {
    var domain: ResaleTicket {
        ResaleTicket(
            id: resaleId,
            ticketId: ticketId,
            price: priceKrw,
            seatCode: seatCode,
            status: resaleStatus,
            photoCardUrl: URL(string: photoCardUrl)
        )
    }
}
