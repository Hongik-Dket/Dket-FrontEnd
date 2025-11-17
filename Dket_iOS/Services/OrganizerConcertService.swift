//
//  OrganizerEventService.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

// MARK: - OrganizerConcertServicing
protocol OrganizerConcertServicing {
    func fetchDetail(concertId: Int64) async throws -> ConcertDetail
    func fetchSession(concertId: Int64, sessionId: Int64) async throws -> SessionDetail
    func createConcert(_ req: ConcertCreateRequestDTO) async throws -> Int64
    func verifyProof(proofId: String) async throws -> TicketVerifyResponseDTO
}

// MARK: - OrganizerConcertService
struct OrganizerConcertService: OrganizerConcertServicing {

    private let api = APIClient.shared

    // MARK: - 공연 상세 조회
    func fetchDetail(concertId: Int64) async throws -> ConcertDetail {
        let wrapper = try await api.get(
            .organizerConcertDetail(concertId: concertId),
            as: APIResponse<ConcertDetailDTO>.self
        )
        return wrapper.result.domain
    }

    // MARK: - 세션 상세 조회
    func fetchSession(concertId: Int64, sessionId: Int64) async throws -> SessionDetail {
        let wrapper = try await api.get(
            .organizerSession(concertId: concertId, sessionId: sessionId),
            as: APIResponse<SessionDetailDTO>.self
        )
        return wrapper.result.domain
    }

    // MARK: - 공연 등록
    func createConcert(_ req: ConcertCreateRequestDTO) async throws -> Int64 {
        let wrapper = try await api.post(
            .organizerCreateConcert,
            body: req,
            as: CreateConcertResponseDTO.self
        )
        return wrapper.result.concertId
    }

    // MARK: - 티켓 입장 증명 검증
    func verifyProof(proofId: String) async throws -> TicketVerifyResponseDTO {
        let body = TicketVerifyRequestDTO(proofId: proofId)
        let response: APIResponse<TicketVerifyResponseDTO> = try await api.post(
            .organizerTicketVerify,
            body: body,
            as: APIResponse<TicketVerifyResponseDTO>.self
        )

        guard response.isSuccess else {
            throw NSError(domain: "VerifyFail", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: response.message])
        }

        return response.result
    }
}
