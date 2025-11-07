//
//  OrganizerEventService.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

protocol OrganizerConcertServicing {
    func fetchDetail(concertId: Int64) async throws -> ConcertDetail
    func fetchSession(concertId: Int64, sessionId: Int64) async throws -> SessionDetail
    func createConcert(_ req: ConcertCreateRequestDTO) async throws -> Int64
    
    func fetchEntryCode(concertId: Int64, sessionId: Int64) async throws -> String
    func verifyTicket(ticketId: Int64) async throws -> TicketDetail
}

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
    
    // MARK: - 티켓 검증
    func verifyTicket(ticketId: Int64) async throws -> TicketDetail {
        let wrapper: APIResponse<TicketDetailDTO> = try await api.get(
            .ticketDetailById(id: ticketId),
            as: APIResponse<TicketDetailDTO>.self
        )
        return wrapper.result.domain
    }
    
    // MARK: - 입장 인증번호 조회
    func fetchEntryCode(concertId: Int64, sessionId: Int64) async throws -> String {
        print("🟢 [DEBUG] 입장 인증번호 요청 (concertId: \(concertId), sessionId: \(sessionId))")
        let response: APIResponse<SessionEnterResultDTO> = try await api.get(
            .organizerSessionEnter(concertId: concertId, sessionId: sessionId),
            as: APIResponse<SessionEnterResultDTO>.self
        )
        
        print("✅ [DEBUG] 인증번호 응답 수신 — entryCode: \(response.result.entryCode)")
        return response.result.entryCode
    }
}


extension JSONDecoder {
    static func makeConcertDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        let dateF = DateFormatter()
        dateF.calendar = Calendar(identifier: .iso8601)
        dateF.dateFormat = "yyyy-MM-dd"
        
        let dateTimeF = DateFormatter()
        dateTimeF.calendar = dateF.calendar
        dateTimeF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let s = try container.decode(String.self)
            if let dt = dateF.date(from: s) { return dt }
            if let dt = dateTimeF.date(from: s) { return dt }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "지원되지 않는 날짜 형식: \(s)"
            )
        }
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }
}
