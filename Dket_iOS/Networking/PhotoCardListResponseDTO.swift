//
//  PhotoCardListResponseDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

struct PhotoCardListResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [PhotoCardItemDTO]
}

struct PhotoCardItemDTO: Decodable {
    let photoCardId: Int64
    let imageUrl: String
    let ticketId: Int64  

    func toDomain() -> PhotoCardItem {
        .init(photoCardId: photoCardId, imageUrl: imageUrl)
    }
}
