//
//  EventDetailViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import SwiftUI

@MainActor
final class EventDetailViewModel: ObservableObject {

    // MARK: - Output
    @Published private(set) var state: LoadingState = .idle
    @Published private(set) var detail: EventDetail?
    @Published private(set) var selectedSession: SessionDetail?
    @Published private(set) var sessionCache: [Int64: SessionDetail] = [:]
    @Published var selectedSessionId: Int64? {
        didSet { Task { await loadSessionIfNeeded() } }
    }

    // MARK: - Dependency
    private let service: OrganizerEventServicing
    private let eventId: Int64

    

    // MARK: - Init
    init(eventId: Int64,
         service: OrganizerEventServicing = OrganizerEventService()) {
        self.eventId = eventId
        self.service = service
    }

    // MARK: - Lifecycle
    func onAppear() {
        Task { await loadDetail() }
    }

    // MARK: - Private
    private func loadDetail() async {
        state = .loading
        do {
            let d = try await service.fetchDetail(eventId: eventId)
            detail = d
            state  = .loaded

            // 첫 번째 회차 자동 선택
            if let first = d.sessionIds.first {
                selectedSessionId = first            // ← didSet 트리거
            }
        } catch {
            state = .failed(error)
        }
    }

    private func loadSessionIfNeeded() async {
        guard let sid = selectedSessionId else { return }

        // 이미 캐시가 있으면 즉시 반영
        if let cached = sessionCache[sid] {
            selectedSession = cached
            return
        }

        do {
            let detail = try await service.fetchSession(eventId: eventId,
                                                        sessionId: sid)
            sessionCache[sid] = detail
            selectedSession   = detail
        } catch {
            print("❌ Session Detail Error:", error)
        }
    }
}
