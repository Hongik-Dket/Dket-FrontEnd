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
        return dto.result.todayEvents.map { $0.domain }   // 서버 spec 에 맞춰 수정
    }
}

/* 오늘 / closed / all 결과용 DTO 래퍼 */
private struct TodayResultDTO : Decodable { let todayEvents: [EventDTO] }
private struct ClosedResultDTO: Decodable { let recentlyClosedApplyEvents: [EventDTO] }
private struct AllResultDTO   : Decodable { let todayEvents: [EventDTO] } // 예시
