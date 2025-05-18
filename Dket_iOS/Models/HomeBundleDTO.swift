//
//  HomeBundleDTO.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/27/25.
//

struct HomeBundleDTO: Decodable {
    let todayEvents:               [EventDTO]
    let recentlyClosedApplyEvents: [EventDTO]
    let allEvents:                 [EventDTO]
    let endedEvents:               [EventDTO]
}

extension HomeBundleDTO {
    var domain: HomeBundle {
        HomeBundle(
            today:           todayEvents.map { $0.domain },
            recentlyClosed:  recentlyClosedApplyEvents.map { $0.domain },
            all:             allEvents.map { $0.domain },
            ended:           endedEvents.map { $0.domain })
    }
}

// ViewModel이 한꺼번에 보관하는 묶음
struct HomeBundle {
    let today:          [Event]
    let recentlyClosed: [Event]
    let all:            [Event]
    let ended:          [Event]
}
