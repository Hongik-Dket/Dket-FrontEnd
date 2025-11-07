//
//  ResaleTicketViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation
import SwiftUI

@MainActor
final class ResalePurchaseViewModel: ObservableObject {
    // MARK: - Published
    @Published var ticketInfo: ResaleTicketInfo? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var didPurchase: Bool = false
    
    private let service: ResaleTradeServicing
    private let resaleId: Int64

    // MARK: - Init
    init(resaleId: Int64, service: ResaleTradeServicing = ResaleTradeService()) {
        self.resaleId = resaleId
        self.service = service
    }

    // MARK: - Step 1️⃣ 예약
    func reserveTicket() async {
            isLoading = true
            defer { isLoading = false }
            do {
                ticketInfo = try await service.reserveResaleTicket(resaleId: resaleId)
            } catch let error as NetworkError {
                if case .status(let code) = error {
                    switch code {
                    case 400:
                        self.errorMessage = "이미 거래 중인 티켓입니다."
                    case 403:
                        self.errorMessage = "티켓을 구매할 수 없는 사용자입니다."
                    default:
                        self.errorMessage = "오류가 발생했습니다. (\(code))"
                    }
                } else {
                    self.errorMessage = error.localizedDescription
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }

    // MARK: - Step 2️⃣ 구매
    func purchaseTicket() async {
        guard let ticketInfo = ticketInfo else { return }
        isLoading = true
        do {
            let result = try await service.purchaseResaleTicket(ticketId: ticketInfo.resaleId)
            print("✅ 구매 완료: \(result)")
            self.didPurchase = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Step 3️⃣ 예약 취소
    func cancelReservation() async {
        do {
            try await service.cancelResaleReservation(resaleId: resaleId)
            print("🟢 예약 취소 성공")
        } catch {
            print("❌ 예약 취소 실패: \(error.localizedDescription)")
        }
    }
}
