//
//  PhotoCardListResponseDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

struct PhotoCardListResponseDTO: Decodable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: [PhotoCardItemDTO]
}
