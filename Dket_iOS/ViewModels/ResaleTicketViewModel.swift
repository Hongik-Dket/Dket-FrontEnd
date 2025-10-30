//
//  ResaleTicketViewModel.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation
import SwiftUI

@MainActor
final class ResaleTicketViewModel: ObservableObject {
    // MARK: - Published Properties (View에서 관찰)
    @Published var ticket: ResaleTicket?   
    @Published var showingError: Bool = false
    @Published var isLoading: Bool = false
    @Published var resalePurchase: ResalePurchase?
    @Published var errorMessage: String?
    
    // 구매 버튼 눌렀는지 여부
    @Published var didPurchase: Bool = false
    
    // MARK: - Dependencies
    private let service: ResaleTradeServicing
    
    // MARK: - Init
    init(service: ResaleTradeServicing = ResaleTradeService()) {
        self.service = service
    }
    
    // MARK: - API Call
    func purchase(ticketId: Int64) async {
        isLoading = true
        errorMessage = nil
        didPurchase = false
        
        do {
            let result = try await service.purchaseResaleTicket(ticketId: ticketId)
            resalePurchase = result
            didPurchase = true
        } catch {
            errorMessage = mapError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Error Mapping
    private func mapError(_ error: Error) -> String {
        if let netErr = error as? NetworkError {
            switch netErr {
            case .status(let code): return "서버 오류: \(code)"
            case .unauthorized: return "인증이 필요합니다."
            default: return "알 수 없는 네트워크 오류"
            }
        }
        return error.localizedDescription
    }
}
