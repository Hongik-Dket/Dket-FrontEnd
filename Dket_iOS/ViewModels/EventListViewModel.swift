//
//  EventListViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/7/25.
//

import Foundation

/// 어떤 리스트를 불러올지 구분하는 타입
enum ListingType {
    
    // 개최자용
    case today      // 오늘 공연
    case closed     // 최근 응모 마감 공연
    case all        // 전체(개최한) 공연
    
    // 구매자용
    case popular
    case applied
    case purchased
    case entire
    
    var isBuyerList: Bool {
        switch self {
        case .popular, .applied, .purchased, .entire:
            return true
        default:
            return false
        }
    }
    
    
    /// 화면 타이틀 기본값
    var defaultTitle: String {
        switch self {
        case .today:     return "오늘 공연"
        case .closed:    return "최근 응모 마감 공연"
        case .all:       return "전체 공연"
        case .popular:   return "인기 공연"
        case .applied:   return "응모한 공연"
        case .purchased: return "구매한 공연"
        case .entire:    return "전체 공연"
        }
    }
}

@MainActor
final class EventListViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var state: LoadingState = .idle
    
    private let type: ListingType
    
    // 의존성 분기
    private let organizerService: OrganizerHomeServicing?
    private let buyerService: BuyerHomeServicing?
    
    init(type: ListingType) {
        self.type = type
        switch type {
        case .today, .closed, .all:
            self.organizerService = OrganizerHomeService()
            self.buyerService = nil
        case .popular, .applied, .purchased, .entire:
            self.organizerService = nil
            self.buyerService = BuyerHomeService()
        }
    }
    
    func load() {
        Task {
            state = .loading
            do {
                let list: [Event]
                switch type {
                    // 개최자 홈화면
                case .today:
                    list = try await organizerService?.fetchToday() ?? []
                case .closed:
                    list = try await organizerService?.fetchClosed() ?? []
                case .all:
                    list = try await organizerService?.fetchAll() ?? []
                    
                    // 구매자 홈화면
                case .popular:
                    list = try await buyerService?.fetchPopular() ?? []
                case .applied:
                    list = try await buyerService?.fetchApplied() ?? []
                case .purchased:
                    list = try await buyerService?.fetchPurchased() ?? []
                case .entire:
                    list = try await buyerService?.fetchEntire() ?? []
                }
                
                self.events = list
                state = .loaded
            } catch {
                state = .failed(error)
            }
        }
    }
}
