//
//  ResaleLookUpViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import SwiftUI

@MainActor
final class ResaleLookUpViewModel: ObservableObject {
    @Published var resaleTickets: [ResaleTicket] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var selectedSessionId: Int64? = nil {
        didSet {
            Task { await fetchTickets() }
        }
    }
    
    private let service: ResaleServicing
    
    init(service: ResaleServicing = ResaleService()) {
        self.service = service
    }
    
    func fetchTickets() async {
        guard let sessionId = selectedSessionId else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            print("📡 Fetching resale tickets for sessionId=\(sessionId)")
            let fetched = try await service.fetchResaleTickets(sessionId: sessionId)
            resaleTickets = fetched
            print("✅ 리세일 티켓 \(fetched.count)개 로드 완료")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ 리세일 티켓 조회 실패: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
