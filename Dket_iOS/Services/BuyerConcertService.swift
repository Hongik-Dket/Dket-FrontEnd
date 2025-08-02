//
//  BuyerEventService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

protocol BuyerConcertServicing {
    func fetchDetail(concertId: Int64) async throws -> (ConcertDetail, [BuyerSessionDetail])
}

struct BuyerConcertService: BuyerConcertServicing {
    private let api = APIClient.shared

    func fetchDetail(concertId: Int64) async throws -> (ConcertDetail, [BuyerSessionDetail]) {
        let wrapper = try await api.get(
            .buyerConcertDetail(concertId: concertId),
            as: APIResponse<BuyerConcertDetailDTO>.self
        )
        let dto = wrapper.result
        return (dto.domain, dto.sessionDomainList)
    }
}
