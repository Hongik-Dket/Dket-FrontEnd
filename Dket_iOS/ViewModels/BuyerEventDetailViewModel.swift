//
//  BuyerDetailViewModel.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation
import Combine

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

    private let service: BuyerEventServicing

    // MARK: - Init
    init(eventId: Int64, service: BuyerEventServicing = BuyerEventService()) {
        self.eventId = eventId
        self.service = service
    }

    // MARK: - Lifecycle
    func onAppear() async {
        await fetch()
    }

    func fetch() async {
        state = .loading
        do {
            let (event, sessions) = try await service.fetchDetail(eventId: eventId)
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
        } catch {
            print("[Error] Fetch BuyerEventDetail failed: \(error)")
            self.state = .failed(error)
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
            } else {
                floatingButtonTitle = "티켓 응모하기"
                isFloatingButtonEnabled = false
            }

        case .applyClosed:
            switch session.applyStatus {
            case .selected:
                floatingButtonTitle = "티켓 결제하기"
                isFloatingButtonEnabled = true
            case .paid:
                floatingButtonTitle = "티켓 조회하기"
                isFloatingButtonEnabled = true
            case .notSelected:
                floatingButtonTitle = "티켓 결제하기"
                isFloatingButtonEnabled = false
            default:
                floatingButtonTitle = ""
                isFloatingButtonEnabled = false
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
    }
}
