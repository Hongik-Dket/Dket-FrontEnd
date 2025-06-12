//
//  BuyerDetailViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation
import Combine

enum BuyerSessionUIState {
    case notApplied           // 응모 안함
    case applied              // 응모 완료
    case notSelected          // 미당첨
    case selectedUnpaid       // 당첨 & 결제 안함
    case paid                 // 결제 완료
    case canceledButBuyable   // 당첨이었지만 미결제 → 잔여티켓으로 전환됨
    case buyable              // 응모는 안됐지만 잔여티켓 있음
    case soldOut              // 잔여티켓 없음
    case enterable            // 입장 가능 (공연 중 + 티켓 소유)
    case none                 // 상태 없음 (선택 세션 없음 등)
}

@MainActor
final class BuyerEventViewModel: ObservableObject {
    // MARK: - Input
    let eventId: Int64
    
    // MARK: - Output (Published for View)
    @Published var isLoading = false
    @Published var eventDetail: EventDetail?
    @Published var sessionList: [BuyerSessionDetail] = []
    @Published var selectedSessionId: Int64?
    @Published var errorMessage: String?
    
    // computed property: 선택된 세션 정보
    var selectedSession: BuyerSessionDetail? {
        guard let id = selectedSessionId else { return nil }
        return sessionList.first(where: { $0.id == id })
    }
    
    var remainingTickets: Int? {
        guard let event = eventDetail,
              let session = selectedSession else { return nil }
        return max(event.capacity - session.paidCount, 0)
    }
    
    var applyStatusText: String? {
        guard let session = selectedSession else { return nil }
        switch session.applyStatus {
        case .applied: return "응모 완료"
        case .notSelected: return "미당첨"
        case .selected: return "결제 필요"
        case .paid: return "결제 완료"
        case .canceled: return "결제 안함"
        case nil: return "미응모"
        }
    }
    
    var floatingButtonText: String? {
        guard let event = eventDetail,
              let session = selectedSession else { return nil }
        
        let status = event.status
        let applyStatus = session.applyStatus
        let remaining = remainingTickets ?? 0
        
        switch status {
        case .applyOpen:
            return applyStatus == nil ? "티켓 응모하기" : nil
        case .applyClosed:
            if applyStatus == .selected {
                return "티켓 결제하기"
            } else if applyStatus == .paid {
                return "티켓 조회하기"
            } else {
                return nil
            }
        case .ticketed:
            if applyStatus == .paid {
                return "티켓 조회하기"
            } else if (applyStatus == .canceled || applyStatus == .notSelected), remaining > 0 {
                return "티켓 구매하기"
            } else {
                return nil
            }
        case .inProgress:
            if applyStatus == .paid {
                return "공연 입장하기"
            } else if remaining > 0 {
                return "티켓 구매하기"
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    var isFloatingButtonEnabled: Bool {
        guard let text = floatingButtonText else { return false }
        guard let event = eventDetail else { return false }
        
        // 구매 가능 시간 제한 (공연 시작 2시간 전까지)
        if text.contains("티켓 구매") || text.contains("공연 입장") {
            if let selected = selectedSession {
                let now = Date()
                let startTime = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: selected.date)!
                let limit = Calendar.current.date(byAdding: .hour, value: -2, to: startTime)!
                return now < limit
            }
        }
        
        return true
    }
    
    // MARK: - Init
    init(eventId: Int64) {
        self.eventId = eventId
    }
    
    // MARK: - API 호출
    func fetchEventDetail() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let dto: BuyerEventDetailDTO = try await APIClient.request(
                endpoint: .buyerEventDetail(eventId: eventId)
            )
            self.eventDetail = dto.domain
            self.sessionList = dto.sessionDomainList
            self.selectedSessionId = sessionList.first?.id // 초기 세션 선택
        } catch {
            self.errorMessage = "공연 정보를 불러오는 데 실패했습니다."
            print("❌ Error fetching buyer event detail:", error.localizedDescription)
        }
    }
    
    // MARK: - 세션 선택
    func selectSession(sessionId: Int64) {
        selectedSessionId = sessionId
    }
}

struct BuyerSessionUIRenderInfo {
    let uiState: BuyerSessionUIState
    let statusText: String?
    let buttonTitle: String?
    let buttonEnabled: Bool
}

extension BuyerEventViewModel {
    func computeSessionUIState(session: BuyerSessionDetail,
                               eventStatus: EventStatus,
                               capacity: Int,
                               currentDate: Date = Date()) -> BuyerSessionUIRenderInfo {
        
        let remainTicket = capacity - session.paidCount
        let applyStatus = session.applyStatus
        let hasTicket = session.ticketId != nil
        
        switch eventStatus {
        case .applyOpen:
            switch applyStatus {
            case .none:
                return .init(uiState: .notApplied,
                             statusText: "미응모",
                             buttonTitle: "티켓 응모하기",
                             buttonEnabled: true)
            case .applied:
                return .init(uiState: .applied,
                             statusText: "응모 완료",
                             buttonTitle: "티켓 응모하기",
                             buttonEnabled: false)
            default:
                return .init(uiState: .none, statusText: nil, buttonTitle: nil, buttonEnabled: false)
            }
            
        case .applyClosed:
            switch applyStatus {
            case .notSelected:
                return .init(uiState: .notSelected,
                             statusText: "미당첨",
                             buttonTitle: "티켓 결제하기",
                             buttonEnabled: false)
            case .selected:
                return .init(uiState: .selectedUnpaid,
                             statusText: "결제 필요",
                             buttonTitle: "티켓 결제하기",
                             buttonEnabled: true)
            case .paid:
                return .init(uiState: .paid,
                             statusText: "결제 완료",
                             buttonTitle: "티켓 조회하기",
                             buttonEnabled: true)
            default:
                return .init(uiState: .none, statusText: nil, buttonTitle: nil, buttonEnabled: false)
            }
            
        case .ticketed:
            switch applyStatus {
            case .paid:
                return .init(uiState: .paid,
                             statusText: "결제 완료",
                             buttonTitle: "티켓 조회하기",
                             buttonEnabled: true)
            case .canceled:
                if remainTicket > 0 {
                    return .init(uiState: .canceledButBuyable,
                                 statusText: "당첨(미결제)",
                                 buttonTitle: "티켓 구매하기",
                                 buttonEnabled: true)
                } else {
                    return .init(uiState: .soldOut,
                                 statusText: "잔여티켓 없음",
                                 buttonTitle: "티켓 구매하기",
                                 buttonEnabled: false)
                }
            case .notSelected:
                if remainTicket > 0 {
                    return .init(uiState: .buyable,
                                 statusText: "미당첨",
                                 buttonTitle: "티켓 구매하기",
                                 buttonEnabled: true)
                } else {
                    return .init(uiState: .soldOut,
                                 statusText: "미당첨",
                                 buttonTitle: "티켓 구매하기",
                                 buttonEnabled: false)
                }
            default:
                return .init(uiState: .none, statusText: nil, buttonTitle: nil, buttonEnabled: false)
            }
            
        case .inProgress:
            if hasTicket {
                return .init(uiState: .enterable,
                             statusText: nil,
                             buttonTitle: "공연 입장하기",
                             buttonEnabled: true)
            } else if remainTicket > 0 {
                let now = currentDate
                let sessionDate = session.date
                let limitDate = Calendar.current.date(byAdding: .hour, value: -2, to: sessionDate) ?? sessionDate
                
                if now < limitDate {
                    return .init(uiState: .buyable,
                                 statusText: nil,
                                 buttonTitle: "티켓 구매하기",
                                 buttonEnabled: true)
                } else {
                    return .init(uiState: .soldOut,
                                 statusText: nil,
                                 buttonTitle: "티켓 구매하기",
                                 buttonEnabled: false)
                }
            } else {
                return .init(uiState: .soldOut,
                             statusText: nil,
                             buttonTitle: "티켓 구매하기",
                             buttonEnabled: false)
            }
            
        default:
            return .init(uiState: .none, statusText: nil, buttonTitle: nil, buttonEnabled: false)
        }
    }
}
