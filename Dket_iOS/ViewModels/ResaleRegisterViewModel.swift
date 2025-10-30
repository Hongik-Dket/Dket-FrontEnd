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
    // MARK: - Properties
    @Published var ticket: TicketDetail
    @Published var priceText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    @Published var showSuccessAlert: Bool = false
    
    // 온체인 호출을 위한 신호
    @Published var shouldTriggerOnChain: Bool = false
    
    private let service: ResaleTradeServicing
    
    // MARK: - Init
    init(ticket: TicketDetail, service: ResaleTradeServicing = ResaleTradeService()) {
        self.ticket = ticket
        self.service = service
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
            let success = try await service.registerResale(ticketId: ticket.ticketId, price: price)
            if success {
                showSuccessAlert = true
                shouldTriggerOnChain = true  // 서버 성공 시 온체인 전송을 트리거
            } else {
                errorMessage = "티켓 판매 등록에 실패했습니다. 다시 시도해주세요."
                showErrorAlert = true
            }
        } catch {
            errorMessage = mapError(error)
            showErrorAlert = true
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
