//
//  ResaleTicketService.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

protocol ResaleTradeServicing {
    func reserveResaleTicket(resaleId: Int64) async throws -> ResaleTicketInfo
    func purchaseResaleTicket(ticketId: Int64) async throws -> ResalePurchase
    func cancelResaleReservation(resaleId: Int64) async throws
    func registerResale(ticketId: Int64, price: Int) async throws -> ResaleRegisterResponseDTO
}

final class ResaleTradeService: ResaleTradeServicing {
    
    // MARK: - 예약 (거래대기 상태로 변경)
    func reserveResaleTicket(resaleId: Int64) async throws -> ResaleTicketInfo {
        let endpoint = Endpoint.resaleReserve(resaleId: resaleId)

        let response: APIResponse<ResaleTicketInfoDTO> = try await APIClient.shared.patch(
            endpoint,
            as: APIResponse<ResaleTicketInfoDTO>.self
        )
        
        return response.result.domain
    }
    
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
    
    // MARK: - 예약 취소 (페이지 이탈 or 시간 만료)
        func cancelResaleReservation(resaleId: Int64) async throws {
            let endpoint = Endpoint.resaleReserve(resaleId: resaleId)
            try await APIClient.shared.delete(endpoint)
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
