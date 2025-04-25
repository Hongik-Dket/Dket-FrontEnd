//
//  MockEventData.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/24/25.
//

import Foundation

struct MockEventData {
    static let today: [Event] = [
        Event(name: "프로미스나인 보고싶다",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment,
              enrollmentStart: "2025.02.21 10:00",
              enrollmentEnd:   "2025.02.28 16:00"),
        Event(name: "송하영",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment,
              enrollmentStart: "2025.02.21 10:00",
              enrollmentEnd:   "2025.02.28 16:00"),
        
        Event(name: "쵝오",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment,
              enrollmentStart: "2025.02.21 10:00",
              enrollmentEnd:   "2025.02.28 16:00"),
    ]
    static let closed: [Event] = [
        Event(name: "더미",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment,
              enrollmentStart: "2025.02.21 10:00",
              enrollmentEnd:   "2025.02.28 16:00"),
        Event(name: "데이터",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment,
              enrollmentStart: "2025.02.21 10:00",
              enrollmentEnd:   "2025.02.28 16:00"),
    ]
    static let hosted: [Event] = [
        Event(name: "넣어봄",
              location: "서울 올림픽공원",
              dateRange: "2025.04.25",
              bannerImageName: "banner1",
              state: .preEnrollment,
              enrollmentStart: "2025.02.21 10:00",
              enrollmentEnd:   "2025.02.28 16:00"),
    ]
}
