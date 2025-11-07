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
    @Published var ticketInfo: ResaleTicketInfo? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var didPurchase: Bool = false

    private let tradeService: ResaleTradeServicing
    private let buyService: BuyResaleWithSigServicing
    private let resaleId: Int64

    init(
        resaleId: Int64,
        tradeService: ResaleTradeServicing = ResaleTradeService(),
        buyService: BuyResaleWithSigServicing = BuyResaleWithSigService()
    ) {
        self.resaleId = resaleId
        self.tradeService = tradeService
        self.buyService = buyService
    }

    // MARK: - Step 1️⃣ 예약
    func reserveTicket() async {
        isLoading = true
        defer { isLoading = false }

        do {
            ticketInfo = try await tradeService.reserveResaleTicket(resaleId: resaleId)

        } catch let error as NetworkError {
            if case .status(let code) = error {
                switch code {
                case 400, 403:
                    // ⚠️ 여기서 body를 다시 파싱해보자
                    if let apiError = await parseApiError(from: error) {
                        switch apiError.code {
                        case "RESALE_4005":
                            self.errorMessage = "이미 거래 중인 티켓입니다."
                        case "RESALE_4006":
                            self.errorMessage = "티켓을 구매할 수 없는 사용자입니다."
                        default:
                            self.errorMessage = apiError.message ?? "오류가 발생했습니다."
                        }
                    } else {
                        // fallback
                        self.errorMessage = (code == 403)
                            ? "티켓을 구매할 수 없는 사용자입니다."
                            : "이미 거래 중인 티켓입니다."
                    }
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
    func purchaseTicket(walletAddress: String) async {
        guard let info = ticketInfo else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            // 1️⃣ 서버에 서명 요청
            print("🟢 [DEBUG] 리세일 구매 서명 요청 (resaleId: \(resaleId))")
            let sigResponse = try await tradeService.purchaseResaleTicket(resaleId: info.resaleId)
            print("✅ [DEBUG] 구매 서명 응답 수신 — tokenId=\(sigResponse.tokenId), expireAt=\(sigResponse.expireAt)")

            // 2️⃣ 온체인 트랜잭션 호출
            try await buyService.sendBuyResaleTransaction(
                resaleId: info.resaleId,
                tokenId: sigResponse.tokenId,
                expireAt: sigResponse.expireAt,
                signature: sigResponse.signature,
                priceWei: info.priceWei,
                from: walletAddress
            )

            print("🎉 [SUCCESS] 리세일 구매 완료")
            self.didPurchase = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Step 3️⃣ 예약 취소
    func cancelReservation() async {
        do {
            try await tradeService.cancelResaleReservation(resaleId: resaleId)
            print("🟢 예약 취소 성공")
        } catch {
            print("❌ 예약 취소 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - API 에러 메시지 파싱용 헬퍼
private func parseApiError(from error: NetworkError) async -> APIErrorResponse? {
    guard case .status = error else { return nil }
    guard let response = APIClient.shared.lastResponseData else { return nil }

    return try? JSONDecoder().decode(APIErrorResponse.self, from: response)
}

struct APIErrorResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String?
}
