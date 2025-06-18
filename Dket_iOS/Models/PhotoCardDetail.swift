//
//  PhotoCardDetail.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

struct PhotoCardDetail: Decodable {
    let photoCardId: Int64
    let ticketId: Int64
    let imageUrl: String
    let eventTitle: String
    let sessionDate: Date?
    let ticketNumber: String
    let nftUrl: String
}
