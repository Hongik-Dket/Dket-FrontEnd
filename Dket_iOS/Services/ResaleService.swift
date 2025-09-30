//
//  ResaleService.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import Foundation

protocol ResaleServicing {
    func fetchResaleTickets(sessionId: Int64) async throws -> [ResaleTicket]
}

final class ResaleService: ResaleServicing {
    func fetchResaleTickets(sessionId: Int64) async throws -> [ResaleTicket] {
        // 1️⃣ API 호출
        let endpoint = Endpoint.resaleTickets(sessionId: sessionId)
        
        // 2️⃣ APIResponse<[ResaleTicketDTO]>로 디코딩
        let response: APIResponse<[ResaleTicketDTO]> = try await APIClient.shared.get(endpoint, as: APIResponse<[ResaleTicketDTO]>.self)
        
        // 3️⃣ DTO → 도메인 모델 변환
        return response.result.map { $0.domain }
    }
}
