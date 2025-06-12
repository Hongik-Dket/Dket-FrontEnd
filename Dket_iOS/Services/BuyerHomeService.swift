//
//  BuyerHomeService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/2/25.
//

import Foundation

protocol BuyerHomeServicing {
    func fetchHome() async throws -> BuyerHomeBundle
    func fetchPopular() async throws -> [Event]
    func fetchApplied() async throws -> [Event]
    func fetchPurchased() async throws -> [Event]
    func fetchEntire() async throws -> [Event]
}

struct BuyerHomeService: BuyerHomeServicing {
    private let api = APIClient.shared
    
    func fetchHome() async throws -> BuyerHomeBundle {
        let wrapper = try await api.get(.buyerHomeMain, as: APIResponse<BuyerHomeBundleDTO>.self)
        return wrapper.result.domain
    }
    
    func fetchPopular() async throws -> [Event] {
        let wrapper = try await api.get(.buyerHomePopular, as: APIResponse<EventListResponse>.self)
        return wrapper.result.events.map { $0.domain }
    }

    func fetchApplied() async throws -> [Event] {
        let wrapper = try await api.get(.buyerHomeApplied, as: APIResponse<EventListResponse>.self)
        return wrapper.result.events.map { $0.domain }
    }

    func fetchPurchased() async throws -> [Event] {
        let wrapper = try await api.get(.buyerHomePurchased, as: APIResponse<EventListResponse>.self)
        return wrapper.result.events.map { $0.domain }
    }

    func fetchEntire() async throws -> [Event] {
        let wrapper = try await api.get(.buyerHomeEntire, as: APIResponse<EventListResponse>.self)
        return wrapper.result.events.map { $0.domain }
    }
}

private struct EventListResponse: Decodable {
    let eventCardList: [EventDTO]
    
    var events: [EventDTO] { eventCardList }
}
