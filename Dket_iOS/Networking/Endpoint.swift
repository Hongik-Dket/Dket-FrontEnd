//
//  Endpoint.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

enum Endpoint {
    case organizerHome
    case organizerToday
    case organizerClosed
    case organizerAll
    case organizerEventDetail(eventId: Int64)
    case organizerSession(eventId: Int64, sessionId: Int64)
    case organizerCreateEvent
    case organizerTicket(eventId: Int64, ticketId: String)
    
    var path: String {
        switch self {
        case .organizerHome:   return "/api/organizer/home"
        case .organizerToday:  return "/api/organizer/home/today"
        case .organizerClosed: return "/api/organizer/home/closed"
        case .organizerAll:    return "/api/organizer/home/all"
        case .organizerEventDetail(let id):
            return "/api/organizer/events/\(id)"
        case .organizerSession(let eid, let sid):
            return "/api/organizer/events/\(eid)/\(sid)"
        case .organizerCreateEvent: return "/api/organizer/events"
        case .organizerTicket(let eid, let tid):
            return "/api/organizer/events/\(eid)/\(tid)"
        }
    }
    
    
    var method: String {
        switch self {
        case .organizerCreateEvent: return "POST"
        case .organizerTicket:  return "GET"
        default:          return "GET"
        }
    }
}

