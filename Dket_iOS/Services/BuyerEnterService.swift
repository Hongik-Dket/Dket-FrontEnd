//
//  BuyerEnterService.swift
//  Dket_iOS
//
//  Created by M-136 on 11/8/25.
//

import Foundation

//MARK: - 임시
protocol BuyerEnterServicing {
    func fetchChallenge(ticketId: Int64, entryCode: String) async throws -> ChallengeResult
}

struct BuyerEnterService: BuyerEnterServicing {
    private let api = APIClient.shared
    
    func fetchChallenge(ticketId: Int64, entryCode: String) async throws -> ChallengeResult {
        let wrapper = try await api.get(
            .buyerEnterPrepare(ticketId: ticketId, entryCode: entryCode),
            as: BuyerEnterPrepareResponseDTO.self
        )
        guard let result = wrapper.result else {
            throw URLError(.badServerResponse)
        }
        return result
    }
}
