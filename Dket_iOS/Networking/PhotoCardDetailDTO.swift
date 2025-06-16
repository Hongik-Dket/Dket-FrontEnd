//
//  PhotoCardDetailDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

struct PhotoCardDetailDTO: Decodable {
    let photoCardId: Int64
    let ticketId: Int64
    let imageUrl: String
    let eventTitle: String
    let sessionDate: String
    let ticketNumber: String
    let nftUrl: String
    
    var domain: PhotoCardDetail {
        PhotoCardDetail(
            photoCardId: photoCardId,
            ticketId: ticketId,
            imageUrl: imageUrl,
            eventTitle: eventTitle,
            sessionDate: DateFormatter.yyyyDMMDdd.date(from: sessionDate),
            ticketNumber: ticketNumber,
            nftUrl: nftUrl
        )
    }
}
