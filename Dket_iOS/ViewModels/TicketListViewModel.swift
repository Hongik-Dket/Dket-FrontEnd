//
//  TicketListViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import Foundation

@MainActor
final class TicketListViewModel: ObservableObject {
    @Published var tickets: [MyTicket] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let ticketService: TicketServicing

    init(ticketService: TicketServicing = TicketService()) {
        self.ticketService = ticketService
    }

    func fetchTickets() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await ticketService.fetchMyTickets()
            tickets = result
        } catch {
            errorMessage = "티켓 목록을 불러오는 데 실패했습니다."
            print("❌ TicketListViewModel fetchTickets error: \(error)")
        }

        isLoading = false
    }
}
