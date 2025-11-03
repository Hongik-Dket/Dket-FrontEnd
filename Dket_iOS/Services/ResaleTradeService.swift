//
//  ResaleTicketService.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

protocol ResaleTradeServicing {
    func purchaseResaleTicket(ticketId: Int64) async throws -> ResalePurchase
    func registerResale(ticketId: Int64, price: Int) async throws -> ResaleRegisterResponseDTO
}

final class ResaleTradeService: ResaleTradeServicing {
    
    // MARK: - 리세일 티켓 구매
    func purchaseResaleTicket(ticketId: Int64) async throws -> ResalePurchase {
        let endpoint = Endpoint.resalePurchase(ticketId: ticketId)
        
        let response: APIResponse<ResalePurchaseDTO> = try await APIClient.shared.post(
            endpoint,
            body: EmptyBody(),
            as: APIResponse<ResalePurchaseDTO>.self
        )
        
        return response.result.domain
    }
    
    // MARK: - 내 티켓 리세일 등록
    func registerResale(ticketId: Int64, price: Int) async throws -> ResaleRegisterResponseDTO {
        let endpoint = Endpoint.resaleRegister(ticketId: ticketId, price: price)
        let body = ResaleRegisterRequestDTO(price: price)
        
        let response: APIResponse<ResaleRegisterResponseDTO> = try await APIClient.shared.post(
            endpoint,
            body: body,
            as: APIResponse<ResaleRegisterResponseDTO>.self
        )

        return response.result
    }
}

struct EmptyBody: Encodable {}
