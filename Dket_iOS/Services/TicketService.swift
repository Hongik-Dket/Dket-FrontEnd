//
//  TicketService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/16/25.
//

import Foundation

protocol TicketServicing {
    func fetchBuyerTicketDetail(_ ticketId: Int64) async throws -> TicketDetail
    
    func fetchTicketById(_ id: Int64) async throws -> TicketDetail
    func fetchTicketByNumber(_ number: String) async throws -> TicketVerifyResponseDTO
    func fetchMyTickets() async throws -> [MyTicket]
    func enterTicket(ticketId: Int64) async throws -> APIResponseWithoutResult
}

struct TicketService: TicketServicing {
    
    func fetchBuyerTicketDetail(_ ticketId: Int64) async throws -> TicketDetail {
        try await APIClient.shared.get(
            .buyerTicketDetail(ticketId: ticketId),
            as: APIResponse<TicketDetailDTO>.self
        ).result.domain
    }
    
    func fetchTicketById(_ id: Int64) async throws -> TicketDetail {
        try await APIClient.shared.get(.ticketDetailById(id: id), as: APIResponse<TicketDetailDTO>.self)
            .result
            .domain
    }
    
    func fetchTicketByNumber(_ number: String) async throws -> TicketVerifyResponseDTO {
            // /api/organizer/tickets?ticketNumber={ticketNumber}
            let response = try await APIClient.shared.get(
                .ticketDetailByNumber(number: number),
                as: APIResponse<TicketNumberResponseDTO>.self
            )

            guard response.isSuccess else {
                throw NSError(
                    domain: "TicketFetch",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: response.message]
                )
            }

            // 서버가 ticketId만 내려주므로, verifyProof의 리턴 DTO와 맞춰줌
            return TicketVerifyResponseDTO(
                identityType: "PASSPORT", // ✅ 티켓번호 검증은 무조건 오프라인 확인용이므로
                ticketId: response.result.ticketId
            )
        }
    
    func fetchMyTickets() async throws -> [MyTicket] {
        try await APIClient.shared.get(.buyerTicketList, as: APIResponse<[MyTicketDTO]>.self)
            .result
            .map { $0.domain }
    }
    
    func enterTicket(ticketId: Int64) async throws -> APIResponseWithoutResult {
            try await APIClient.shared.patch(
                .organizerEnterTicket(ticketId: ticketId),
                as: APIResponseWithoutResult.self
            )
        }
}
