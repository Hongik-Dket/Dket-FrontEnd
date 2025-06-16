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
    @Published private(set) var verificationState: VerificationState = .idle
    
    // 티켓 검증 상태
    enum VerificationState: Equatable {
            case idle
            case verifying
            case success(message: String)
            case failure(error: String)
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
                // 1) 이벤트 상세 가져오기
                let d = try await service.fetchDetail(eventId: eventId)

                // 2) 각 세션별로 병렬(또는 순차)로 상세 가져오기
                var newCache: [Int64: SessionDetail] = [:]
                for sid in d.sessionIds {
                    let s = try await service.fetchSession(
                        eventId: eventId,
                        sessionId: sid
                    )
                    newCache[sid] = s
                }

                // 3) UI 업데이트
                detail = d
                sessionCache = newCache
                state = .loaded

                // 4) 첫 번째 회차 자동 선택 & selectedSession 세팅
                if let first = d.sessionIds.first {
                    selectedSessionId = first
                    selectedSession   = newCache[first]
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
    
    // MARK: - Public: 티켓 검증 호출
        func verifyTicket(with code: String) {
            Task {
                verificationState = .verifying
                do {
                    // 가장 먼저 선택된 세션 ID
                    let sid = selectedSession?.id
                           ?? selectedSessionId
                           ?? (detail?.sessionIds.first ?? 0)
                    // 서버 호출 (프로토콜에 verifyTicket 추가되어 있어야 합니다)
                    let message = try await service.verifyTicket(
                        eventId: eventId,
                        ticketId: code
                    )
                    let msg = "좌석 번 입장 처리되었습니다."
                                    verificationState = .success(message: msg)
                                } catch {
                                    verificationState = .failure(error: error.localizedDescription)
                                }
            }
        }
    
    
    func refresh() async {
        print("🔄 개최자 공연상세보기 refresh() 실행")
        await onAppear()
    }
}



