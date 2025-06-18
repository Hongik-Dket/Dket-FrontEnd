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
    
    @Published var verifiedTicket: TicketDetail?
    
    @Published var verificationFailed = false
    
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
            let d = try await service.fetchDetail(eventId: eventId)
            
            var newCache: [Int64: SessionDetail] = [:]
            for sid in d.sessionIds {
                let s = try await service.fetchSession(
                    eventId: eventId,
                    sessionId: sid
                )
                newCache[sid] = s
            }
            
            detail = d
            sessionCache = newCache
            state = .loaded
            
            // 첫 번째 회차 자동 선택, selectedSession 세팅
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
    
    func verifyTicket(with code: String) {
        Task {
            verificationState = .verifying
            do {
                let ticket = try await service.verifyTicket(ticketId: Int64(code) ?? 0)
                self.verifiedTicket = ticket
                verificationState = .success(message: "입장 처리되었습니다.")
            } catch {
                self.verificationFailed = true
                
                let errorMessage = mapErrorMessage(error)
                verificationState = .failure(error: errorMessage)
            }
        }
    }
    
    
    func refresh() async {
        print("🔄 개최자 공연상세보기 refresh() 실행")
        await onAppear()
    }
}

private func mapErrorMessage(_ error: Error) -> String {
    let rawMessage = error.localizedDescription.lowercased()
    
    if rawMessage.contains("not found") || rawMessage.contains("invalid") {
        return "유효하지 않은 티켓입니다."
    } else if rawMessage.contains("already entered") {
        return "이미 입장 처리된 티켓입니다."
    } else {
        return "유효하지 않은 티켓입니다."
    }
}



