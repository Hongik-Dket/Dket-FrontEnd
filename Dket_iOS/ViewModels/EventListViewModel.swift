//
//  EventListViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/7/25.
//

import Foundation

/// 어떤 리스트를 불러올지 구분하는 타입
enum ListingType {
  case today      // 오늘 공연
  case closed     // 최근 응모 마감 공연
  case all        // 전체(개최한) 공연

  /// 화면 타이틀 기본값
  var defaultTitle: String {
    switch self {
    case .today:  return "오늘 공연"
    case .closed: return "최근 응모 마감 공연"
    case .all:    return "전체 공연"
    }
  }
}

@MainActor
final class EventListViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var state: LoadingState = .idle

    private let service: OrganizerHomeServicing
    private let type: ListingType
    
    /// 모드를 주입받도록 init 변경
        init(type: ListingType,
             service: OrganizerHomeServicing = OrganizerHomeService()) {
            self.type    = type
            self.service = service
        }

    /// 타입에 따라 알맞은 API 호출
        func load() {
            Task {
                state = .loading
                do {
                    let list: [Event]
                    switch type {
                    case .today:
                        list = try await service.fetchToday()
                    case .closed:
                        list = try await service.fetchClosed()
                    case .all:
                        list = try await service.fetchAll()
                    }
                    self.events = list
                    state = .loaded
                } catch {
                    state = .failed(error)
                }
            }
        }
}
