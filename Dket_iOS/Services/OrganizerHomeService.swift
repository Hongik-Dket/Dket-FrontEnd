//
//  OrganizerHomeService.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

protocol OrganizerHomeServicing {
    func fetchHome()  async throws -> HomeBundle
    func fetchToday() async throws -> [Event]
    func fetchClosed()async throws -> [Event]
    func fetchAll()   async throws -> [Event]
}

struct OrganizerHomeService: OrganizerHomeServicing {
    private let api = APIClient.shared
    
    func fetchHome() async throws -> HomeBundle {
        let wrapper = try await api.get(.organizerHome, as: APIResponse<HomeBundleDTO>.self)
        return wrapper.result.domain
    }
    
    func fetchToday() async throws -> [Event] {
        let dto = try await api.get(.organizerToday, as: APIResponse<TodayResultDTO>.self)
        return dto.result.todayEvents.map { $0.domain }
    }
    
    func fetchClosed() async throws -> [Event] {
        let dto = try await api.get(.organizerClosed, as: APIResponse<ClosedResultDTO>.self)
        return dto.result.recentlyClosedApplyEvents.map { $0.domain }
    }
    
    func fetchAll() async throws -> [Event] {
        let dto = try await api.get(.organizerAll, as: APIResponse<AllResultDTO>.self)
        return dto.result.allEvents.map { $0.domain }
    }
}

private struct TodayResultDTO : Decodable {
    let eventCardList: [EventDTO]
    var todayEvents: [EventDTO] { eventCardList }
}
private struct ClosedResultDTO: Decodable {
    let eventCardList: [EventDTO]
    var recentlyClosedApplyEvents: [EventDTO] { eventCardList }
}
private struct AllResultDTO   : Decodable {
    let eventCardList: [EventDTO]
    var allEvents: [EventDTO] { eventCardList }
}

