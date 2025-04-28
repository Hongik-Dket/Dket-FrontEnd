//
//  EventDetailViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation
import Combine

@MainActor
final class EventDetailViewModel: ObservableObject {
    @Published var state: LoadingState = .idle
    @Published var detail: EventDetail?
    @Published var selectedSession: SessionDetail?
    
    private let service: OrganizerEventServicing
    private let eventId: Int64
    
    init(eventId: Int64,
         service: OrganizerEventServicing = OrganizerEventService()) {
        self.eventId = eventId
        self.service = service
    }
    
    func onAppear() {
        Task { await load() }
    }
    
    func selectSession(id: Int64) {
        Task {
            do {
                selectedSession = try await service.fetchSession(eventId: eventId,
                                                                 sessionId: id)
            } catch {
                // 에러 처리
            }
        }
    }
    
    private func load() async {
        state = .loading
        do {
            detail = try await service.fetchDetail(of: eventId)
            state = .loaded
            
            // 기본 선택 = 첫 회차
            if let first = detail?.sessionIds.first {
                selectSession(id: first)
            }
        } catch {
            state = .failed(error)
        }
    }
}
