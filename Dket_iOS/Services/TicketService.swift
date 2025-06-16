//
//  TicketService.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/16/25.
//

import Foundation

protocol TicketServicing {
    func fetchTicketById(_ id: Int64) async throws -> TicketDetail
    func fetchTicketByNumber(_ number: String) async throws -> TicketDetail
    
}

struct TicketService: TicketServicing {
    func fetchTicketById(_ id: Int64) async throws -> TicketDetail {
        try await APIClient.shared.get(.ticketDetailById(id: id), as: APIResponse<TicketDetailDTO>.self)
            .result
            .domain
    }
    
    func fetchTicketByNumber(_ number: String) async throws -> TicketDetail {
        try await APIClient.shared.get(.ticketDetailByNumber(number: number), as: APIResponse<TicketDetailDTO>.self)
            .result
            .domain
    }
}
