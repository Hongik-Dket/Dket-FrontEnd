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
    case buyerPurchase(eventId: Int64, sessionId: Int64)
    case buyerEventDetail(eventId: Int64)

    case buyerTicketDetail(ticketId: String)
    case buyerTicketList
    case buyerEnter(ticketId: String)
    case buyerPhotocard(ticketId: String)

    // MARK: - Auth / Wallet
    case connectWallet    // 추후 POST /api/auth/wallet 등으로 확장 가능

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
        case .buyerPurchase(let eid, let sid):
            return "/api/buyer/events/\(eid)/sessions/\(sid)/purchase"
        case .buyerEventDetail(let eid):
            return "/api/buyer/events/\(eid)"

        case .buyerTicketDetail(let tid):
            return "/api/buyer/tickets/\(tid)"
        case .buyerTicketList:
            return "/api/buyer/tickets"
        case .buyerEnter(let tid):
            return "/api/buyer/tickets/\(tid)/enter"
        case .buyerPhotocard(let tid):
            return "/api/buyer/tickets/\(tid)/photocard"

        case .connectWallet:
            return "/api/auth/wallet"
        }
    }

    // MARK: - Method 설정 (기본은 GET)
    var method: String {
        switch self {
        case .organizerCreateEvent,
             .connectWallet,
             .buyerApply,
             .buyerPurchase:
            return "POST"
        case .buyerEnter:
            return "PATCH"
        default:
            return "GET"
        }
    }
}
