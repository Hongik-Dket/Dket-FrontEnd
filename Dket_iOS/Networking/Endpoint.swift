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
    case organizerConcertDetail(concertId: Int64)
    case organizerSession(concertId: Int64, sessionId: Int64)
    case organizerCreateConcert
    case organizerTicket(concertId: Int64, ticketId: String)
    
    // MARK: - Buyer (구매자)
    case buyerHomeMain
    case buyerHomePopular
    case buyerHomeApplied
    case buyerHomePurchased
    case buyerHomeEntire
    
    case buyerApply(concertId: Int64, sessionId: Int64)
    case buyerTicketPrice(sessionId: Int64)
    case buyerConcertDetail(concertId: Int64)
    
    // 개최자 티켓
    case ticketDetailById(id: Int64)
    case ticketDetailByNumber(number: String)
    case ticketEnter(ticketId: Int64)
    
    // 구매자 티켓
    case buyerTicketList
    case buyerEnter(ticketId: String)
    case buyerTicketDetail(ticketId: Int64)
    
    case buyerPhotocardList
    case buyerPhotocardDetail(ticketId: Int64)
    
    case resaleTickets(sessionId: Int64)
    case resaleRegister(ticketId: Int64, price: Int)
    case resalePurchase(ticketId: Int64)
    
    // MARK: - Auth / Wallet
    case userWalletInfo
    
    case loginMetaMask                 // 메타마스크 로그인
    case foreignSignUp                 // 여권 회원가입
    case koreanSignUp
    case completeMetaMaskSignUp        // 회원가입 후 메타마스크 연결 완료
    
    // MARK: - Computed Path
    var path: String {
        switch self {
        // Organizer
        case .organizerHome: return "/api/organizer/home"
        case .organizerToday: return "/api/organizer/home/today"
        case .organizerClosed: return "/api/organizer/home/closed"
        case .organizerAll: return "/api/organizer/home/all"
        case .organizerConcertDetail(let cid):
            return "/api/organizer/concerts/\(cid)"
        case .organizerSession(let cid, let sid):
            return "/api/organizer/concerts/\(cid)/\(sid)"
        case .organizerCreateConcert:
            return "/api/organizer/concerts"
        case .organizerTicket(let cid, let tid):
            return "/api/organizer/concerts/\(cid)/\(tid)"
            
        // Buyer
        case .buyerHomeMain: return "/api/buyer/home"
        case .buyerHomePopular: return "/api/buyer/home/popular"
        case .buyerHomeApplied: return "/api/buyer/home/applied"
        case .buyerHomePurchased: return "/api/buyer/home/purchased"
        case .buyerHomeEntire: return "/api/buyer/home/entire"
            
        case .buyerApply(let cid, let sid):
            return "/api/buyer/concerts/\(cid)/sessions/\(sid)/apply"
        case .buyerTicketPrice(let sid):
            return "/api/buyer/concerts/\(sid)/price"
        case .buyerConcertDetail(let cid):
            return "/api/buyer/concerts/\(cid)"
            
        // Organizer Ticket
        case .ticketDetailById(let id):
            return "/api/tickets"
        case .ticketDetailByNumber(let number):
            return "/api/tickets"
        case .ticketEnter(let ticketId):
            return "/api/tickets/organizer/\(ticketId)/enter"
            
            
        // Buyer Ticket
        case .buyerTicketList:
            return "/api/user/tickets"
        case .buyerEnter(let tid):
            return "/api/buyer/tickets/\(tid)/enter"
        case .buyerTicketDetail(let ticketId):
            return "/api/buyer/tickets/\(ticketId)"
            
        // Buyer PhotoCard
        case .buyerPhotocardList:
            return "/api/user/photocards"
        case .buyerPhotocardDetail(let tid):
            return "/api/user/photocards/\(tid)"
            
        // Resale
        case .resaleTickets:
                return "/api/resales"
        case .resaleRegister(let ticketId, _):
            return "/api/resales/\(ticketId)"
        case .resalePurchase(let ticketId):
            return "/api/resales/\(ticketId)/purchase"
            
        // Wallet
        case .userWalletInfo:
            return "/api/user/wallet"
            
        case .loginMetaMask: return "/api/auth/login/metamask"
        case .foreignSignUp: return "/api/auth/signup/passport"
        case .koreanSignUp: return ""
        case .completeMetaMaskSignUp: return "/api/user/signup/metamask/complete"
        
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .ticketDetailById(let id):
            return [URLQueryItem(name: "id", value: "\(id)")]
        case .ticketDetailByNumber(let number):
            return [URLQueryItem(name: "number", value: number)]
        case .resaleTickets(let sessionId):
            return [URLQueryItem(name: "sessionId", value: "\(sessionId)")]
        default:
            return nil
        }
    }
    
    // MARK: - Method 설정 
    var method: String {
        switch self {
        case .organizerCreateConcert,
                .buyerApply,
                .buyerTicketPrice,
                .resalePurchase,
                .resaleRegister,
                .foreignSignUp,
                .koreanSignUp,
                .loginMetaMask,
                .completeMetaMaskSignUp:
            return "POST"
        case .buyerEnter,
                .ticketEnter:
            return "PATCH"
        default:
            return "GET"
        }
    }
}

extension Endpoint {
    /// Authorization 헤더 필요 여부
    var requiresAuth: Bool {
        switch self {
        case .foreignSignUp,
                .koreanSignUp:
            return false
        default: 
            return true
        }
    }
}
