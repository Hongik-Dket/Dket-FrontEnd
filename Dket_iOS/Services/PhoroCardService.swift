//
//  PhoroCardService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

protocol PhotoCardServicing {
    func fetchPhotoCard(ticketId: Int64) async throws -> PhotoCardDetail
}

final class PhotoCardService: PhotoCardServicing {
    func fetchPhotoCard(ticketId: Int64) async throws -> PhotoCardDetail {
        let endpoint = Endpoint.buyerPhotocardDetail(ticketId: ticketId) // ✅ 수정됨
        let dto = try await APIClient.request(endpoint: endpoint) as PhotoCardDetailDTO
        return dto.domain
    }
}
