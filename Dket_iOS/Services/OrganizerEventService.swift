//
//  OrganizerEventService.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

protocol OrganizerEventServicing {
    func fetchDetail(eventId: Int64) async throws -> EventDetail
    func fetchSession(eventId: Int64, sessionId: Int64) async throws -> SessionDetail
    func createEvent(_ req: EventCreateRequestDTO) async throws -> Int64
    
    func verifyTicket(
        ticketId: Int64
    ) async throws -> TicketDetail
    
}

struct OrganizerEventService: OrganizerEventServicing {
    
    private let api = APIClient.shared
    
    func fetchDetail(eventId: Int64) async throws -> EventDetail {
        let wrapper = try await api.get(.organizerEventDetail(eventId: eventId),
                                        as: APIResponse<EventDetailDTO>.self)
        return wrapper.result.domain
    }
    
    func fetchSession(eventId: Int64, sessionId: Int64) async throws -> SessionDetail {
        let wrapper = try await api.get(.organizerSession(eventId: eventId,
                                                          sessionId: sessionId),
                                        as: APIResponse<SessionDetailDTO>.self)
        return wrapper.result.domain
    }
    
    func createEvent(_ req: EventCreateRequestDTO) async throws -> Int64 {
        let wrapper = try await api.post(.organizerCreateEvent,
                                         body: req,
                                         as: CreateEventResponseDTO.self)
        return wrapper.result.eventId
    }
    
    func verifyTicket(
        ticketId: Int64
    ) async throws -> TicketDetail {
        let wrapper: APIResponse<TicketDetailDTO> = try await api.get(
            .ticketDetailById(id: ticketId),
            as: APIResponse<TicketDetailDTO>.self
        )
        return wrapper.result.domain
    }
    
}

extension JSONDecoder {
    static func makeEventDecoder() -> JSONDecoder {
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
