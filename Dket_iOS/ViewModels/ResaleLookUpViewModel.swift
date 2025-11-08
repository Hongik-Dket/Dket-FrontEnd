//
//  ResaleLookUpViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import SwiftUI

@MainActor
final class ResaleLookUpViewModel: ObservableObject {
    // MARK: - Input
    let service: ResaleServicing
    
    // MARK: - Output
    @Published var resaleTickets: [ResaleTicket] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // 선택된 세션 ID
    @Published var selectedSessionId: Int64? = nil
    
    init(service: ResaleServicing = ResaleService()) {
        self.service = service
    }
    
    // MARK: - 리세일 티켓 조회
    func fetchResaleTickets(sessionId: Int64) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        print("🟢 [DEBUG] 리세일 조회 시작 (sessionId: \(sessionId))")
        
        do {
            let tickets = try await service.fetchResaleTickets(sessionId: sessionId)
            await MainActor.run {
                self.resaleTickets = tickets
                self.selectedSessionId = sessionId
                print("✅ [DEBUG] 조회 성공 — \(tickets.count)개")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                print("❌ [DEBUG] 리세일 조회 실패: \(error.localizedDescription)")
            }
        }
    }
}
