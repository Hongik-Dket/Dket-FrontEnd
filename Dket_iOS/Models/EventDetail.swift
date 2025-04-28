//
//  EventDetail.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/28/25.
//

import Foundation

struct EventDetail: Identifiable, Equatable {
    let id: Int64
    let title: String
    let posterUrl: URL
    let location: String
    let period: ClosedRange<Date>
    let startTime: Date   // 시각만 필요하면 Date-Components를 써도 OK
    let endTime:   Date
    let ageLimit:  AgeLimit
    let price:     Int
    let applyStart: Date
    let applyEnd:   Date
    let capacity:   Int
    let status:     EventStatus
    let sessionIds: [Int64]     // 날짜순
}
