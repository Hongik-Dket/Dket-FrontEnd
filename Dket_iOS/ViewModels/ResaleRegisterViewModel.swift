//
//  ResaleRegisterViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 10/30/25.
//

import Foundation
import SwiftUI

@MainActor
final class ResaleRegisterViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var ticket: TicketDetail
    @Published var priceText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var isProcessingProof = false
    
    // 온체인 호출을 위한 신호 & 데이터
    @Published var shouldTriggerOnChain: Bool = false
    @Published var tokenId: Int64? = nil
    @Published var resaleId: Int64? = nil
    
    private let service: ResaleTradeServicing
    private let approveService: ApproveNFTServicing
    
    // MARK: - Init
    init(ticket: TicketDetail,
             service: ResaleTradeServicing = ResaleTradeService(),
             approveService: ApproveNFTServicing = ApproveNFTService()) {
            self.ticket = ticket
            self.service = service
            self.approveService = approveService
        }
    
    // MARK: - 판매 등록 API 호출
    func registerResale() async {
            guard let price = Int(priceText), price > 0 else {
                errorMessage = "유효한 판매 금액을 입력해주세요."
                showErrorAlert = true
                return
            }

            isLoading = true
            defer { isLoading = false }

            do {
                // ① 서버 등록 요청
                let response = try await service.registerResale(ticketId: ticket.ticketId, price: price)
                print("✅ 등록 완료 — resaleId=\(response.resaleId), tokenId=\(response.tokenId)")

                // ② Face ID 서명
                let signedData = try await BiometricKeyManager.shared.sign(challenge: response.challenge)
                let signatureHex = signedData.toHexString()

                let privateKey = try BiometricKeyManager.shared.loadOrCreateKeyPair()
                let pubData = try BiometricKeyManager.shared.getPublicKeyData(from: privateKey)
                guard let compressed = BiometricKeyManager.shared.compressPublicKey(pubData) else {
                    throw NSError(domain: "Biometric", code: 0, userInfo: [NSLocalizedDescriptionKey: "공개키 압축 실패"])
                }

                // ③ 서버에 서명 결과 제출
                await MainActor.run { self.isProcessingProof = true }
                do {
                    try await service.signResaleTicket(
                        ticketId: ticket.ticketId,
                        resaleId: response.resaleId,
                        challengeId: response.challengeId,
                        signature: signatureHex,
                        publicKey: compressed.toHexString()
                    )

                    // 검증 완료 후 약간의 지연을 두고 닫기 (UX 개선)
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1초
                    await MainActor.run { self.isProcessingProof = false }

                } catch {
                    await MainActor.run {
                        self.isProcessingProof = false
                        self.errorMessage = "서버 검증 실패: \(error.localizedDescription)"
                        self.showErrorAlert = true
                    }
                    return
                }

                // ④ 온체인 Approve 트리거
                self.tokenId = response.tokenId
                self.shouldTriggerOnChain = true

                // ⑤ 실제 Approve 실행 → MetaMask로 전환
                let tokenId = response.tokenId
                if let walletAddress = UserDefaults.standard.string(forKey: "userWalletAddress") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Task {
                            do {
                                try await self.approveService.sendApproveTransaction(
                                    tokenId: tokenId,
                                    from: walletAddress
                                )
                                print("🟢 온체인 approve 완료 — MetaMask 트랜잭션 성공")
                                self.showSuccessAlert = true
                            } catch {
                                print("❌ MetaMask 트랜잭션 실패: \(error.localizedDescription)")
                                self.errorMessage = error.localizedDescription
                                self.showErrorAlert = true
                            }
                        }
                    }
                }

            } catch {
                self.errorMessage = error.localizedDescription
                self.showErrorAlert = true
                self.isProcessingProof = false
                print("❌ 판매 등록 실패: \(error.localizedDescription)")
            }
        }
    
    // MARK: - Error Mapping
    private func mapError(_ error: Error) -> String {
        if let netErr = error as? NetworkError {
            switch netErr {
            case .status(let code): return "서버 오류 발생 (코드: \(code))"
            case .unauthorized: return "인증이 필요합니다. 로그인 후 다시 시도해주세요."
            default: return "네트워크 연결 오류가 발생했습니다."
            }
        }
        return error.localizedDescription
    }
}
