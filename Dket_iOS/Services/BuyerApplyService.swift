//
//  BuyerApplyService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/14/25.
//

import Foundation

protocol BuyerApplyServicing {
    func apply(to eventId: Int64, sessionId: Int64) async throws -> ApplyResponseDTO
}

import Foundation

final class BuyerApplyService: BuyerApplyServicing {
    func apply(to eventId: Int64, sessionId: Int64) async throws -> ApplyResponseDTO {
        struct EmptyBody: Encodable {}

        let endpoint = Endpoint.buyerApply(eventId: eventId, sessionId: sessionId)
        return try await APIClient.shared.post(endpoint, body: EmptyBody())
    }
}
