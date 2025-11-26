//
//  BuyerTicketDetailViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/16/25.
//

import Foundation

@MainActor
final class BuyerTicketDetailViewModel: ObservableObject {
    @Published var ticket: BuyerTicketDetail?
    private let ticketService: TicketServicing
    private let ticketId: Int64
    
    init(ticketService: TicketServicing = TicketService(), ticketId: Int64) {
        self.ticketService = ticketService
        self.ticketId = ticketId
    }
    
    func fetch() async {
        do {
            print("구매자 티켓 상세 조회 시작: \(ticketId)")
            let detail = try await ticketService.fetchBuyerTicketDetail(ticketId)
            self.ticket = detail
            print("✅ 티켓 조회 성공: \(detail)")
        } catch {
            print("❌ 티켓 상세 조회 실패: \(error.localizedDescription)")
        }
    }
}
