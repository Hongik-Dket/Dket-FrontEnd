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
import BigInt

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
final class BuyerConcertViewModel: ObservableObject {
    // MARK: - Input
    let concertId: Int64
    
    // MARK: - Output (Published)
    @Published var state: LoadingState = .idle
    @Published var detail: ConcertDetail?
    @Published var sessionList: [BuyerSessionDetail] = []
    @Published var selectedSessionId: Int64?
    @Published var selectedSession: BuyerSessionDetail?
    
    // MARK: - Floating Button
    @Published var floatingButtonTitle: String = ""
    @Published var isFloatingButtonEnabled: Bool = false
    @Published var floatingAction: FloatingActionType = .none
    
    @Published var showApplySuccessAlert: Bool = false
    
    @Published var ticketPriceWei: BigUInt?
    @Published var ticketPriceEthString: String = ""
    @Published var showBuyConfirmAlert: Bool = false
    
    private let service: BuyerConcertServicing
    private let applyService: BuyerApplyServicing
    private let buyTicketService: BuyTicketServicing
    
    @Published var applyResult: ApplyResult = .none
    
    @Published var isPurchasing: Bool = false
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Init
    init(
        concertId: Int64,
        service: BuyerConcertServicing = BuyerConcertService(),
        applyService: BuyerApplyServicing = BuyerApplyService(),
        buyTicketService: BuyTicketServicing = BuyTicketService()
    ) {
        self.concertId = concertId
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
        
        fetchTask = Task {
            await MainActor.run { self.state = .loading }
            
            do {
                let (concert, sessions) = try await service.fetchDetail(concertId: concertId)
                await MainActor.run {
                    self.detail = concert
                    
                    let updatedSessions = sessions.map { session -> BuyerSessionDetail in
                        var s = session
                        s.remainingTickets = max(concert.capacity - session.paidCount, 0)
                        return s
                    }
                    
                    self.sessionList = updatedSessions
                    self.state = .loaded
                    self.isPurchasing = false
                    
                    if let previousId = selectedSessionId,
                       let previous = updatedSessions.first(where: { $0.id == previousId }) {
                        selectedSession = previous
                        updateFloatingButton(for: previous)
                    } else if let first = updatedSessions.first {
                        selectedSessionId = first.id
                        selectedSession = first
                        updateFloatingButton(for: first)
                    }
                }
            } catch {
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    return
                }
                
                await MainActor.run {
                    print("[Error] Fetch BuyerConcertDetail failed: \(error)")
                    self.state = .failed(error)
                }
            }
        }
    }
    
    func applyToSelectedSession() async -> Bool {
        guard let concertId = detail?.id,
              let sessionId = selectedSession?.id else {
            print("[Error] applyToSelectedSession - No session or Concert selected")
            return false
        }
        
        do {
            let responseWrapper = try await APIClient.shared.post(
                .buyerApply(concertId: concertId, sessionId: sessionId),
                body: EmptyBody(),
                as: APIResponse<ApplyResponseDTO>.self
            )
            
            let response = responseWrapper.result
            print("✅ 응모 완료: \(response)")
            await MainActor.run {
                self.showApplySuccessAlert = true
                
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
            if session.ticketId != nil {
                return "결제 완료"
            } else if detail!.capacity > session.paidCount {
                return "구매 가능"
            } else {
                return "품절"
            }
            
        case .inProgress:
            return "공연 중"
        default:
            return ""
        }
    }
    
    func updateFloatingButton(for session: BuyerSessionDetail?) {
        guard let concert = detail else { return }
        guard let session = session else {
            floatingButtonTitle = ""
            isFloatingButtonEnabled = false
            return
        }
        
        if isPurchasing {
            floatingButtonTitle = "결제 진행 중..."
            isFloatingButtonEnabled = false
            floatingAction = .none
            return
        }
        
        switch concert.status {
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
                floatingAction = .view
            } else if session.applyStatus == .canceled && session.buyable {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = true
                floatingAction = .buy
            } else if session.applyStatus == nil && session.buyable {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = true
                floatingAction = .buy
            } else if session.buyable == false {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = false
                floatingAction = .none
            } else {
                floatingButtonTitle = ""
                isFloatingButtonEnabled = false
                floatingAction = .none
            }
            
        case .inProgress:
            if session.ticketId != nil {
                floatingButtonTitle = "공연 입장하기"
                isFloatingButtonEnabled = true
                floatingAction = .enter
            } else if session.buyable {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = true
                floatingAction = .buy
            } else {
                floatingButtonTitle = "티켓 구매하기"
                isFloatingButtonEnabled = false
                floatingAction = .none
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
    
    func preparePurchase() async {
        guard let sessionId = selectedSession?.id else {
            print("❌ 세션 ID 없음")
            return
        }
        
        do {
            let priceWei = try await buyTicketService.getPriceWei(for: sessionId)
            let priceEth: String = {
                let ethDouble = Double(priceWei) / pow(10.0, 18.0)
                return String(format: "%.4f", ethDouble)
            }()
            
            await MainActor.run {
                self.ticketPriceWei = priceWei
                self.ticketPriceEthString = priceEth
                self.showBuyConfirmAlert = true
            }
        } catch {
            print("❌ 가격 조회 실패: \(error)")
        }
    }
    
    func confirmPurchase() async {
        guard let sessionId = selectedSession?.id,
              let walletAddress = UserWalletStore.shared.address,
              let priceWei = ticketPriceWei else {
            print("❌ 정보 부족")
            return
        }
        
        guard !isPurchasing else {
            print("⚠️ 결제 중이므로 무시됨")
            return
        }
        
        await MainActor.run {
            self.isPurchasing = true
            self.isFloatingButtonEnabled = false
            self.floatingButtonTitle = "결제 진행 중..."
        }
        
        do {
            try await buyTicketService.sendBuyTicketTransaction(
                sessionId: sessionId,
                from: walletAddress,
                value: priceWei
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let url = URL(string: "metamask://")!
                let canOpen = UIApplication.shared.canOpenURL(url)
                print("🔍 canOpenURL: \(canOpen)")
                if canOpen {
                    UIApplication.shared.open(url)
                    print("📲 MetaMask로 전환 시도")
                } else {
                    print("❌ MetaMask 딥링크 실패 — 앱 미설치 or Info.plist 누락")
                }
            }
            
            print("✅ 결제 완료")
            showBuyConfirmAlert = false
            await fetch()
            
        } catch {
            print("❌ 결제 실패: \(error)")
        }
        await MainActor.run {
            self.isPurchasing = false
            if let sessionId = self.selectedSessionId,
               let updatedSession = self.sessionList.first(where: { $0.id == sessionId }) {
                self.selectedSession = updatedSession
                self.updateFloatingButton(for: updatedSession)
            } else {
                self.updateFloatingButton(for: nil)
            }
        }
    }
    
    func refresh() async {
        print("🔄 구매자 공연상세보기 refresh() 실행")
        await fetch()
    }
}

