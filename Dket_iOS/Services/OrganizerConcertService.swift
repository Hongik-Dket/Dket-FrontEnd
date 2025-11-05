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
    func verifyTicket(ticketId: Int64) async throws -> TicketDetail
}

struct OrganizerConcertService: OrganizerConcertServicing {
    
    private let api = APIClient.shared
    
    func fetchDetail(concertId: Int64) async throws -> ConcertDetail {
        let wrapper = try await api.get(
            .organizerConcertDetail(concertId: concertId),
            as: APIResponse<ConcertDetailDTO>.self
        )
        return wrapper.result.domain
    }
    
    func fetchSession(concertId: Int64, sessionId: Int64) async throws -> SessionDetail {
        let wrapper = try await api.get(
            .organizerSession(concertId: concertId, sessionId: sessionId),
            as: APIResponse<SessionDetailDTO>.self
        )
        return wrapper.result.domain
    }
    
    func createConcert(_ req: ConcertCreateRequestDTO) async throws -> Int64 {
        let wrapper = try await api.post(
            .organizerCreateConcert,
            body: req,
            as: CreateConcertResponseDTO.self
        )
        return wrapper.result.concertId
    }
    
    func verifyTicket(ticketId: Int64) async throws -> TicketDetail {
        let wrapper: APIResponse<TicketDetailDTO> = try await api.get(
            .ticketDetailById(id: ticketId),
            as: APIResponse<TicketDetailDTO>.self
        )
        return wrapper.result.domain
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
