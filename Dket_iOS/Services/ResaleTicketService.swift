//
//  ResaleTicketService.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

protocol ResaleTicketServicing {
    func purchaseResaleTicket(ticketId: Int64) async throws -> ResalePurchase
}

final class ResaleTicketService: ResaleTicketServicing {
    func purchaseResaleTicket(ticketId: Int64) async throws -> ResalePurchase {
        let endpoint = Endpoint.resalePurchase(ticketId: ticketId)
        
        // POST인데 body가 없으므로 Void를 인코딩해서 보냄
        let response: APIResponse<ResalePurchaseDTO> = try await APIClient.shared.post(
            endpoint,
            body: EmptyBody(), 
            as: APIResponse<ResalePurchaseDTO>.self
        )
        return response.result.domain
    }
}

// 빈 body 전송을 위한 struct
struct EmptyBody: Encodable {}
