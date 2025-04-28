//
//  OrganizerEventService.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

protocol OrganizerEventServicing {
    func fetchDetail(of eventId: Int64) async throws -> EventDetail
    func fetchSession(eventId: Int64, sessionId: Int64) async throws -> SessionDetail
}

struct OrganizerEventService: OrganizerEventServicing {
    private let api = APIClient.shared
    
    func fetchDetail(of eventId: Int64) async throws -> EventDetail {
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
}
