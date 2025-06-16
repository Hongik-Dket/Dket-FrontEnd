//
//  BuyerDetailViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation
import web3swift
import Combine
import UIKit

struct EmptyBody: Encodable {}

enum FloatingActionType: String {
    case apply = "티켓 응모하기"
    case purchase = "티켓 결제하기"
    case buy = "티켓 구매하기"
    case enter = "공연 입장하기"
    case view = "티켓 조회하기"
    case none = ""
}

@MainActor
final class BuyerEventViewModel: ObservableObject {
    // MARK: - Input
    let eventId: Int64
    
    // MARK: - Output (Published)
    @Published var state: LoadingState = .idle
    @Published var detail: EventDetail?
    @Published var sessionList: [BuyerSessionDetail] = []
    @Published var selectedSessionId: Int64?
    @Published var selectedSession: BuyerSessionDetail?
    
    // MARK: - Floating Button
    @Published var floatingButtonTitle: String = ""
    @Published var isFloatingButtonEnabled: Bool = false
    @Published var floatingAction: FloatingActionType = .none
    
    @Published var showApplySuccessAlert: Bool = false
    
    private let service: BuyerEventServicing
    private let applyService: BuyerApplyServicing
    private let buyTicketService: BuyTicketServicing
    
    @Published var applyResult: ApplyResult = .none
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Init
    init(
        eventId: Int64,
        service: BuyerEventServicing = BuyerEventService(),
        applyService: BuyerApplyServicing = BuyerApplyService(),
        buyTicketService: BuyTicketServicing = BuyTicketService()
    ) {
        self.eventId = eventId
        self.service = service
        self.applyService = applyService
        self.buyTicketService = buyTicketService
    }
    
    // MARK: - Lifecycle
    func onAppear() async {
        await fetch()
    }
    
    func fetch() {
        // 이전 fetch 작업이 있다면 취소
        fetchTask?.cancel()
        
        // 새로운 fetch 작업 시작
        fetchTask = Task {
            await MainActor.run { self.state = .loading }
            
            do {
                let (event, sessions) = try await service.fetchDetail(eventId: eventId)
                await MainActor.run {
                    self.detail = event
                    
                    let updatedSessions = sessions.map { session -> BuyerSessionDetail in
                        var s = session
                        s.remainingTickets = max(event.capacity - session.paidCount, 0)
                        return s
                    }
                    
                    self.sessionList = updatedSessions
                    self.state = .loaded

                    if let first = updatedSessions.first {
                        selectedSessionId = first.id
                        selectedSession = first
                        updateFloatingButton(for: first)
                    }
                }
            } catch {
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    // 취소된 요청은 무시
                    return
                }
                
                await MainActor.run {
                    print("[Error] Fetch BuyerEventDetail failed: \(error)")
                    self.state = .failed(error)
                }
            }
        }
    }
    
    func applyToSelectedSession() async -> Bool {
        guard let eventId = detail?.id,
              let sessionId = selectedSession?.id else {
            print("[Error] applyToSelectedSession - No session or event selected")
            return false
        }
        
        do {
            let responseWrapper = try await APIClient.shared.post(
                .buyerApply(eventId: eventId, sessionId: sessionId),
                body: EmptyBody(),
                as: APIResponse<ApplyResponseDTO>.self
            )
            
            let response = responseWrapper.result
            print("✅ 응모 완료: \(response)")
            await MainActor.run {
                        self.showApplySuccessAlert = true
                        
                        // fetch 후 다시 상태 반영
                        if let selected = self.selectedSession {
                            self.updateFloatingButton(for: selected)
                        }
                    }
            return true
        } catch {
            print("[Error] 응모 실패: \(error)")
            return false
        }
    }
    
    func selectSession(_ id: Int64) {
        guard let s = sessionList.first(where: { $0.id == id }) else { return }
        selectedSessionId = id
        selectedSession = s
        updateFloatingButton(for: s)
    }
    
    func isSessionSelectable(_ session: BuyerSessionDetail) -> Bool {
        return detail?.status != .ended
    }
    
    func sessionApplyStatusLabel(_ session: BuyerSessionDetail) -> String {
        switch detail?.status {
        case .applyNotOpened:
            return "미응모"
        case .applyOpen:
            return session.applyStatus == nil ? "미응모" : "응모 완료"
        case .applyClosed:
            switch session.applyStatus {
            case .selected:    return "결제 필요"
            case .paid:        return "결제 완료"
            case .notSelected: return "미당첨"
            case .canceled:    return "당첨 취소"
            default:           return "미응모"
            }
        case .ticketed:
            if session.ticketId != nil { return "결제 완료" }
            else if session.buyable { return "구매 가능" }
            else { return "품절" }
        default:
            return ""
        }
    }
    
    func updateFloatingButton(for session: BuyerSessionDetail?) {
        guard let event = detail else { return }
        guard let session = session else {
            floatingButtonTitle = ""
            isFloatingButtonEnabled = false
            return
        }
        
        switch event.status {
        case .applyNotOpened:
            floatingButtonTitle = "티켓 응모하기"
            isFloatingButtonEnabled = false
            
        case .applyOpen:
            if session.applyStatus == nil {
                floatingButtonTitle = "티켓 응모하기"
                isFloatingButtonEnabled = true
                floatingAction = .apply
            } else {
                floatingButtonTitle = "티켓 응모하기"
                isFloatingButtonEnabled = false
                floatingAction = .none
            }
            
        case .applyClosed:
            switch session.applyStatus {
            case .selected:
                floatingButtonTitle = "티켓 결제하기"
                isFloatingButtonEnabled = true
                floatingAction = .purchase
            case .paid:
                floatingButtonTitle = "티켓 조회하기"
                isFloatingButtonEnabled = true
                floatingAction = .view
            case .notSelected:
                floatingButtonTitle = "티켓 결제하기"
                isFloatingButtonEnabled = false
                floatingAction = .none
            default:
                floatingButtonTitle = ""
                isFloatingButtonEnabled = false
                floatingAction = .none
            }
            
        case .ticketed:
            if session.applyStatus == .paid {
                floatingButtonTitle = "티켓 조회하기"
                isFloatingButtonEnabled = true
            } else if session.applyStatus == .canceled && session.buyable {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = true
            } else if session.applyStatus == nil && session.buyable {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = true
            } else if session.buyable == false {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = false
            } else {
                floatingButtonTitle = ""
                isFloatingButtonEnabled = false
            }
            
        case .inProgress:
            if session.ticketId != nil {
                floatingButtonTitle = "공연 입장하기"
                isFloatingButtonEnabled = true
            } else if session.buyable {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = true
            } else {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = false
            }
            
        case .ended:
            if session.ticketId != nil {
                floatingButtonTitle = "티켓 조회하기"
                isFloatingButtonEnabled = true
            } else {
                floatingButtonTitle = ""
                isFloatingButtonEnabled = false
            }
        }
        print("[DEBUG] 버튼 타이틀: \(floatingButtonTitle), 액션: \(floatingAction.rawValue), enabled: \(isFloatingButtonEnabled)")
    }
    
    func purchaseTicket() async -> Bool {
        guard let sessionId = selectedSession?.id,
              let walletAddress = UserWalletStore.shared.address else {
            print("❌ 지갑 주소 혹은 세션이 없습니다.")
            return false
        }
        
        do {
            let priceWei = try await buyTicketService.getPriceWei(for: sessionId)

            // sendBuyTicketTransaction에 walletAddress는 from으로만 사용됨, priceWei는 msg.value로
            try await buyTicketService.sendBuyTicketTransaction(
                sessionId: sessionId,
                from: walletAddress,
                value: priceWei
            )
            
            if let url = URL(string: "metamask://"), UIApplication.shared.canOpenURL(url) {
                await UIApplication.shared.open(url)
            }

            print("✅ 트랜잭션 전송 완료")
            await fetch()
            return true
        } catch {
            print("❌ 결제 실패: \(error)")
            debugPrint("결제실패에러:", error)
            return false
        }
    }
    
    func refresh() async {
        print("🔄 구매자 공연상세보기 refresh() 실행")
        await fetch()
    }
}

