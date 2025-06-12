//
//  BuyerSessionDetail.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

struct BuyerSessionDetail: Identifiable, Equatable {
    let eventId: Int64
    let id: Int64            // == sessionId
    let date: Date
    
    let applyStatus: ApplyStatus?   // APPLIED, SELECTED, NOT_SELECTED, PAID, CANCELED, nil
    let ticketId: Int64?            // null 이면 소유 안함
    let paidCount: Int              // 잔여 티켓 계산용
    
    var remainingTickets: Int {
        // ViewModel에서 event.capacity를 전달받아 계산
        return 0 // 초기값, 이후 ViewModel에서 덮어씀
    }
    
    var ownershipStatus: Bool {
        return ticketId != nil
    }
}
