//
//  ResaleTicketService.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

protocol ResaleTradeServicing {
    func reserveResaleTicket(resaleId: Int64) async throws -> ResaleTicketInfo
    func purchaseResaleTicket(resaleId: Int64) async throws -> ResalePurchase 
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
    
    // MARK: - 리세일 구매 서명 요청
    func purchaseResaleTicket(resaleId: Int64) async throws -> ResalePurchase {
        let endpoint = Endpoint.resalePurchase(resaleId: resaleId)   // ✅ resaleId로 수정
        
        print("🟢 [DEBUG] 리세일 구매 서명 요청 (resaleId: \(resaleId))")
        
        let response: APIResponse<ResalePurchaseDTO> = try await APIClient.shared.post(
            endpoint,
            body: EmptyBody(),
            as: APIResponse<ResalePurchaseDTO>.self
        )
        
        print("✅ [DEBUG] 구매 서명 응답 수신 — tokenId=\(response.result.tokenId), expireAt=\(response.result.expireAt)")
        
        return response.result.domain
    }
    
    // MARK: - 예약 취소
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
