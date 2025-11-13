//
//  PhoroCardService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

protocol PhotoCardServicing {
    func fetchPhotoCard(ticketId: Int64) async throws -> PhotoCardDetail
    func fetchPhotoCardList() async throws -> [PhotoCardItem]
}

final class PhotoCardService: PhotoCardServicing {
    func fetchPhotoCard(ticketId: Int64) async throws -> PhotoCardDetail {
        let endpoint = Endpoint.buyerPhotocardDetail(ticketId: ticketId)
        let dto = try await APIClient.request(endpoint: endpoint) as PhotoCardDetailDTO
        return dto.domain
    }
    
    func fetchPhotoCardList() async throws -> [PhotoCardItem] {
        let endpoint = Endpoint.buyerPhotocardList
        let dto = try await APIClient.shared.get(endpoint, as: PhotoCardListResponseDTO.self)

        print("✅ 포토카드 수: \(dto.result.count)")
        for card in dto.result {
            print("- \(card.photoCardId) / \(card.imageUrl)")
        }

        return dto.result.map { $0.toDomain() }
    }
}
