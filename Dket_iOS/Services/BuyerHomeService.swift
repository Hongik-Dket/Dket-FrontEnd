//
//  BuyerHomeService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/2/25.
//

import Foundation

protocol BuyerHomeServicing {
    func fetchHome() async throws -> BuyerHomeBundle
    func fetchPopular() async throws -> [Concert]
    func fetchApplied() async throws -> [Concert]
    func fetchPurchased() async throws -> [Concert]
    func fetchEntire() async throws -> [Concert]
}

struct BuyerHomeService: BuyerHomeServicing {
    private let api = APIClient.shared
    
    func fetchHome() async throws -> BuyerHomeBundle {
        let wrapper = try await api.get(.buyerHomeMain, as: APIResponse<BuyerHomeBundleDTO>.self)
        return wrapper.result.domain
    }
    
    func fetchPopular() async throws -> [Concert] {
        let wrapper = try await api.get(.buyerHomePopular, as: APIResponse<ConcertListResponse>.self)
        return wrapper.result.concerts.map { $0.domain }
    }

    func fetchApplied() async throws -> [Concert] {
        let wrapper = try await api.get(.buyerHomeApplied, as: APIResponse<ConcertListResponse>.self)
        return wrapper.result.concerts.map { $0.domain }
    }

    func fetchPurchased() async throws -> [Concert] {
        let wrapper = try await api.get(.buyerHomePurchased, as: APIResponse<ConcertListResponse>.self)
        return wrapper.result.concerts.map { $0.domain }
    }

    func fetchEntire() async throws -> [Concert] {
        let wrapper = try await api.get(.buyerHomeEntire, as: APIResponse<ConcertListResponse>.self)
        return wrapper.result.concerts.map { $0.domain }
    }
}

private struct ConcertListResponse: Decodable {
    let concertCardList: [ConcertDTO]
    
    var concerts: [ConcertDTO] { concertCardList }
}
