//
//  EventDetailViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import SwiftUI

@MainActor
final class ConcertDetailViewModel: ObservableObject {
    
    // MARK: - Output
    @Published private(set) var state: LoadingState = .idle
    @Published private(set) var detail: ConcertDetail?
    @Published private(set) var selectedSession: SessionDetail?
    @Published private(set) var sessionCache: [Int64: SessionDetail] = [:]
    @Published var selectedSessionId: Int64? {
        didSet { Task { await loadSessionIfNeeded() } }
    }
    @Published private(set) var verificationState: VerificationState = .idle
    
    @Published private(set) var isVerifying = false
    
    @Published var verifiedTicket: TicketDetail?
    
    @Published var verificationFailed = false
    
    @Published var identityType: String? = nil
    
    enum VerificationState: Equatable {
        case idle
        case verifying
        case success(message: String)
        case failure(error: String)
    }
    // MARK: - Dependency
    private let service: OrganizerConcertServicing
    private let concertId: Int64
    
    
    // MARK: - Init
    init(concertId: Int64,
         service: OrganizerConcertServicing = OrganizerConcertService()) {
        self.concertId = concertId
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
            let d = try await service.fetchDetail(concertId: concertId)
            
            var newCache: [Int64: SessionDetail] = [:]
            for sid in d.sessionIds {
                let s = try await service.fetchSession(
                    concertId: concertId,
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
            let detail = try await service.fetchSession(concertId: concertId,
                                                        sessionId: sid)
            sessionCache[sid] = detail
            selectedSession   = detail
        } catch {
            print("❌ Session Detail Error:", error)
        }
    }
    
    func verifyTicket(with code: String) {
        Task {
            guard !isVerifying else {
                print("⚠️ 이미 검증 중 — 중복 호출 방지됨")
                return
            }
            isVerifying = true
            defer { isVerifying = false }
            
            verificationState = .verifying
            do {
                guard let proofId = extractUUID(from: code) else {
                    throw NSError(domain: "InvalidQR", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "잘못된 QR코드 형식입니다."])
                }
                
                let result = try await service.verifyProof(proofId: proofId)
                print("✅ 입장 확인 완료 — ticketId: \(result.ticketId), type: \(result.identityType)")
                
                // ✅ identityType 저장
                self.identityType = result.identityType
                
                // ✅ TicketDetail 생성 (birth는 Date 타입)
                self.verifiedTicket = TicketDetail(
                    ticketId: result.ticketId,
                    concertTitle: "",
                    concertDateTime: Date(),
                    buyerName: "",
                    birth: Date(), // ✅ Date 타입으로 수정
                    ticketNumber: "",
                    seatNumber: "",
                    nftUrl: "",
                    isEntered: false,
                    photoCardUrl: "",
                    price: 0,
                    isResaleListed: false
                )
                
                verificationState = .success(message: "입장 처리되었습니다.")
            } catch {
                verificationState = .failure(error: mapErrorMessage(error))
                print("❌ 입장 검증 실패:", error.localizedDescription)
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



private func extractUUID(from code: String) -> String? {
    // UUID 정규식 (8-4-4-4-12)
    let pattern = #"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"#
    if let range = code.range(of: pattern, options: .regularExpression) {
        return String(code[range])
    }
    return nil
}
