//
//  EnteryCodeViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import Foundation

@MainActor
final class EntryCodeViewModel: ObservableObject {
    @Published var entryCode: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let service: OrganizerConcertServicing
    
    init(service: OrganizerConcertServicing = OrganizerConcertService()) {
        self.service = service
    }
    
    /// 입장 인증번호 조회
    func loadEntryCode(concertId: Int64, sessionId: Int64) async {
        isLoading = true
        errorMessage = nil
        do {
            let code = try await service.fetchEntryCode(concertId: concertId, sessionId: sessionId)
            self.entryCode = code
            print("✅ Entry Code fetched: \(code)")
        } catch {
            print("❌ Failed to fetch entry code: \(error.localizedDescription)")
            self.errorMessage = "인증번호를 불러오지 못했습니다."
        }
        isLoading = false
    }
}
