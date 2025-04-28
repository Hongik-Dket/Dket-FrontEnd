//
//  SessionDetail.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation
struct SessionDetail: Identifiable, Equatable {
    let eventId:   Int64
    let id:        Int64          // == sessionId
    let date:      Date
    let applyCount:    Int
    let paidCount:     Int?
    let attendeeCount: Int?
}
