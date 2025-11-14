//
//  PhotoCard.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

struct PhotoCardItem: Identifiable {
    var id: Int64 { photoCardId }
    let photoCardId: Int64
    let imageUrl: String
    let ticketId: Int64   
}
