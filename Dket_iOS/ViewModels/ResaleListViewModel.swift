//
//  Resale.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

@MainActor
final class ResaleViewModel: ObservableObject {
    @Published var sessionDates: [String]
    @Published var selectedDate: String? = nil
    @Published var resaleTickets: [ResaleTicket] = []
    @Published var isLoading: Bool = false

    private let resaleService: ResaleServicing
    private let sessionIdMap: [String: Int64]

    init(sessionDates: [String], sessionIdMap: [String: Int64], resaleService: ResaleServicing = ResaleService()) {
        self.sessionDates = sessionDates
        self.sessionIdMap = sessionIdMap
        self.resaleService = resaleService
    }

    func selectDate(_ date: String) {
        selectedDate = date
        Task {
            await loadResaleTickets(for: date)
        }
    }

    private func loadResaleTickets(for date: String) async {
        guard let sessionId = sessionIdMap[date] else {
            self.resaleTickets = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            resaleTickets = try await resaleService.fetchResaleTickets(sessionId: sessionId)
        } catch {
            print("리세일 티켓 조회 실패:", error)
            resaleTickets = []
        }
    }
}
