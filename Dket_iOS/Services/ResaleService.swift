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
        print("🟢 [DEBUG] 리세일 티켓 조회 요청 (sessionId: \(sessionId))")
        
        // 1️⃣ API 호출 — 응답 타입을 바로 배열로 지정
        let endpoint = Endpoint.resaleTickets(sessionId: sessionId)
        let response: APIResponse<[ResaleCardDto]> = try await APIClient.shared.get(
            endpoint,
            as: APIResponse<[ResaleCardDto]>.self
        )
        
        print("✅ [DEBUG] API 응답 성공 - result 개수: \(response.result.count)")

        // 2️⃣ 정렬 (AVAILABLE → RESERVED → SOLD)
        let sorted = response.result.sorted { a, b in
            if a.resaleStatus == b.resaleStatus {
                return Int(a.seatCode) ?? 0 < Int(b.seatCode) ?? 0
            }
            return a.resaleStatus == .available
        }

        // 3️⃣ Domain 변환
        let domainList = sorted.map { $0.domain }

        print("🟩 [DEBUG] Domain 변환 완료, 반환 개수: \(domainList.count)")
        return domainList
    }
}
