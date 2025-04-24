//
//  MockEventData.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/24/25.
//

import Foundation

struct MockEventData {
    static let today: [Event] = [
        Event(name: "오늘 공연 1",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment),
        Event(name: "오늘 공연 2",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment),
        Event(name: "오늘 공연 3",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment),
    ]
    static let closed: [Event] = [
        Event(name: "마감 공연 1",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment),
        Event(name: "마감 공연 1",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment),
    ]
    static let hosted: [Event] = [
        Event(name: "내가 개최한 공연 1",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment),    ]
}
