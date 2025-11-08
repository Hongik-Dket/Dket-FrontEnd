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
    
    // 온체인 호출을 위한 신호 & 데이터
    @Published var shouldTriggerOnChain: Bool = false
    @Published var tokenId: Int64? = nil
    @Published var resaleId: Int64? = nil
    
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
            // 서버 응답에서 tokenId & resaleId 받기
            let response = try await service.registerResale(ticketId: ticket.ticketId, price: price)
            
            self.resaleId = response.resaleId
            self.tokenId = response.tokenId
            
            print("리세일 등록 성공: resaleId=\(response.resaleId), tokenId=\(response.tokenId)")
            
            showSuccessAlert = true
            
            // 온체인 approve 실행 트리거
            shouldTriggerOnChain = true
            
        } catch {
            errorMessage = "Approve 트랜잭션 실패: \(error.localizedDescription)"
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
