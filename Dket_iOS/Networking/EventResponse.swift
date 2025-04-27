//
//  EventResponse.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

struct EventResponse: Decodable {
    let eventId: Int64
    let title: String
    let location: String
    let startDate: String        // "2025-04-11"
    let endDate: String
    let bannerUrl: String
    let eventStatus: String?     // nullable
    let applyStart: String?
    let applyEnd: String?
}
