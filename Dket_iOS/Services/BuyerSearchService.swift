//
//  BuyerSearchService.swift
//  Dket_iOS
//
//  Created by M-136 on 11/11/25.
//

import Foundation

// MARK: - Protocol
protocol BuyerSearchServicing {
    func searchConcerts(keyword: String) async throws -> [ConcertSearchCardDTO]
}

// MARK: - Implementation
final class BuyerSearchService: BuyerSearchServicing {
    
    func searchConcerts(keyword: String) async throws -> [ConcertSearchCardDTO] {
        do {
            let result: [ConcertSearchCardDTO] = try await APIClient.shared.getDecoded(
                .buyerHomeSearch(keyword: keyword)
            )
            return result
        } catch {
            print("❌ [BuyerSearchService] 공연 검색 실패:", error)
            throw error
        }
    }
}
