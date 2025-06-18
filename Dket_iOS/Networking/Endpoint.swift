//
//  Endpoint.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

import Foundation

enum Endpoint {
    
    // MARK: - Organizer (개최자)
    case organizerHome
    case organizerToday
    case organizerClosed
    case organizerAll
    case organizerEventDetail(eventId: Int64)
    case organizerSession(eventId: Int64, sessionId: Int64)
    case organizerCreateEvent
    case organizerTicket(eventId: Int64, ticketId: String)
    
    // MARK: - Buyer (구매자)
    case buyerHomeMain
    case buyerHomePopular
    case buyerHomeApplied
    case buyerHomePurchased
    case buyerHomeEntire
    
    case buyerApply(eventId: Int64, sessionId: Int64)
    case buyerTicketPrice(sessionId: Int64)
    case buyerEventDetail(eventId: Int64)
    
    case ticketDetailById(id: Int64)
    case ticketDetailByNumber(number: String)
    
    case buyerTicketList
    case ticketEnter(ticketId: Int64)
    case buyerEnter(ticketId: String)
    
    case buyerPhotocardList
    case buyerPhotocardDetail(ticketId: Int64)
    
    // MARK: - Auth / Wallet
    case connectWallet
    
    // MARK: - Computed Path
    var path: String {
        switch self {
            // Organizer
        case .organizerHome: return "/api/organizer/home"
        case .organizerToday: return "/api/organizer/home/today"
        case .organizerClosed: return "/api/organizer/home/closed"
        case .organizerAll: return "/api/organizer/home/all"
        case .organizerEventDetail(let eid):
            return "/api/organizer/events/\(eid)"
        case .organizerSession(let eid, let sid):
            return "/api/organizer/events/\(eid)/\(sid)"
        case .organizerCreateEvent:
            return "/api/organizer/events"
        case .organizerTicket(let eid, let tid):
            return "/api/organizer/events/\(eid)/\(tid)"
            
            // Buyer
        case .buyerHomeMain: return "/api/buyer/home"
        case .buyerHomePopular: return "/api/buyer/home/popular"
        case .buyerHomeApplied: return "/api/buyer/home/applied"
        case .buyerHomePurchased: return "/api/buyer/home/purchased"
        case .buyerHomeEntire: return "/api/buyer/home/entire"
            
        case .buyerApply(let eid, let sid):
            return "/api/buyer/events/\(eid)/sessions/\(sid)/apply"
        case .buyerTicketPrice(let sid):
            return "/api/buyer/events/\(sid)/price"
        case .buyerEventDetail(let eid):
            return "/api/buyer/events/\(eid)"
            
        case .ticketDetailById(let id):
            return "/api/tickets"
        case .ticketDetailByNumber(let number):
            return "/api/tickets"
        case .buyerTicketList:
            return "/api/user/tickets"
            
        case .ticketEnter(let ticketId):
                    return "/api/tickets/organizer/\(ticketId)/enter"
        case .buyerEnter(let tid):
            return "/api/buyer/tickets/\(tid)/enter"
            
        case .buyerPhotocardList:
            return "/api/buyer/photocards"
        case .buyerPhotocardDetail(let tid):
            return "/api/user/photocards/\(tid)"
            
        case .connectWallet:
            return "/api/auth/login/metamask/complete"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .ticketDetailById(let id):
            return [URLQueryItem(name: "id", value: "\(id)")]
        case .ticketDetailByNumber(let number):
            return [URLQueryItem(name: "number", value: number)]
        default:
            return nil
        }
    }
    
    // MARK: - Method 설정 
    var method: String {
        switch self {
        case .organizerCreateEvent,
                .connectWallet,
                .buyerApply,
                .buyerTicketPrice:
            return "POST"
        case .buyerEnter,
                .ticketEnter:
            return "PATCH"
        default:
            return "GET"
        }
    }
}
