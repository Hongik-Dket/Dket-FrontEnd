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

    func signResaleTicket(
        ticketId: Int64,
        resaleId: Int64,
        challengeId: String,
        signature: String,
        publicKey: String
    ) async throws
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
        let endpoint = Endpoint.resalePurchase(resaleId: resaleId)
        
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
        let endpoint = Endpoint.resaleRegister(ticketId: ticketId)
        let body = ResaleRegisterRequestDTO(price: price)
        
        print("📦 [DEBUG] 티켓 리세일 등록 요청 → ticketId: \(ticketId), price: \(price)")

        let response: APIResponse<ResaleRegisterResponseDTO> = try await APIClient.shared.post(
            endpoint,
            body: body,
            as: APIResponse<ResaleRegisterResponseDTO>.self
        )

        guard response.isSuccess else {
            throw NSError(domain: "ResaleTradeService",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: response.message])
        }

        print("""
        [DEBUG] 리세일 등록 완료
        resaleId: \(response.result.resaleId)
        tokenId: \(response.result.tokenId)
        challengeId: \(response.result.challengeId)
        challenge: \(response.result.challenge)
        """)

        return response.result
    }
}

extension ResaleTradeService {
    func signResaleTicket(
        ticketId: Int64,
        resaleId: Int64,
        challengeId: String,
        signature: String,
        publicKey: String
    ) async throws {
        let endpoint = Endpoint.resaleSign(ticketId: ticketId)
        let body = ResaleSignRequestDTO(
            resaleId: resaleId,
            challengeId: challengeId,
            signature: signature,
            publicKey: publicKey
        )

        let response: APIResponseWithoutResult = try await APIClient.shared.patch(
            endpoint,
            body: body,
            as: APIResponseWithoutResult.self
        )

        guard response.isSuccess else {
            throw NSError(domain: "ResaleTradeService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: response.message])
        }

        print("✅ 판매 서명 성공 — resaleId=\(resaleId)")
    }
}

struct EmptyBody: Encodable {}

