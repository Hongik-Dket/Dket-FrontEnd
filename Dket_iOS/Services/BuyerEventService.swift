//
//  BuyerEventService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

protocol BuyerEventServicing {
    func fetchDetail(eventId: Int64) async throws -> (EventDetail, [BuyerSessionDetail])
}

struct BuyerEventService: BuyerEventServicing {
    private let api = APIClient.shared

    func fetchDetail(eventId: Int64) async throws -> (EventDetail, [BuyerSessionDetail]) {
        let wrapper = try await api.get(
            .buyerEventDetail(eventId: eventId),
            as: APIResponse<BuyerEventDetailDTO>.self
        )
        let dto = wrapper.result
        return (dto.domain, dto.sessionDomainList)
    }
}
