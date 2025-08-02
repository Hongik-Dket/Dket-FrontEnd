//
//  OrganizerHomeService.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

protocol OrganizerHomeServicing {
    func fetchHome()  async throws -> HomeBundle
    func fetchToday() async throws -> [Concert]
    func fetchClosed()async throws -> [Concert]
    func fetchAll()   async throws -> [Concert]
}

struct OrganizerHomeService: OrganizerHomeServicing {
    private let api = APIClient.shared
    
    func fetchHome() async throws -> HomeBundle {
        let wrapper = try await api.get(.organizerHome, as: APIResponse<HomeBundleDTO>.self)
        return wrapper.result.domain
    }
    
    func fetchToday() async throws -> [Concert] {
        let dto = try await api.get(.organizerToday, as: APIResponse<TodayResultDTO>.self)
        return dto.result.todayConcerts.map { $0.domain }
    }
    
    func fetchClosed() async throws -> [Concert] {
        let dto = try await api.get(.organizerClosed, as: APIResponse<ClosedResultDTO>.self)
        return dto.result.recentlyClosedApplyConcerts.map { $0.domain }
    }
    
    func fetchAll() async throws -> [Concert] {
        let dto = try await api.get(.organizerAll, as: APIResponse<AllResultDTO>.self)
        return dto.result.allConcerts.map { $0.domain }
    }
}

private struct TodayResultDTO : Decodable {
    let concertCardList: [ConcertDTO]
    var todayConcerts: [ConcertDTO] { concertCardList }
}
private struct ClosedResultDTO: Decodable {
    let concertCardList: [ConcertDTO]
    var recentlyClosedApplyConcerts: [ConcertDTO] { concertCardList }
}
private struct AllResultDTO   : Decodable {
    let concertCardList: [ConcertDTO]
    var allConcerts: [ConcertDTO] { concertCardList }
}

